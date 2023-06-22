//#include <TimeLib.h>
#include <SoftwareSerial.h>
#include <mcp_can.h>
#include <SPI.h>


// set number of hall trips for RPM reading (higher improves accuracy)
bool debug = true;
long unsigned int rxId;
unsigned char len = 0;
unsigned char rxBuf[8];
char msgString[128];
String vtr;  // Array to store serial string
char vtrCache[128];
int speedpin = 8;
const int VOL_PIN = A0;
#define CAN0_INT 2  // Set INT to pin 2
MCP_CAN CAN0(10);   // Set CS to pin 10

typedef enum {
  VOLTAGE,
  UPC,
  PTC,
  CTC,
  OTHER
} request;

void setup() {
  Serial.begin(9600);
  // maybe change back to 115200

  CAN0.setMode(MCP_NORMAL);  // Set operation mode to normal so the MCP2515 sends acks to received data.
  pinMode(VOL_PIN, INPUT);
  pinMode(CAN0_INT, INPUT);  // Configuring pin for /INT input
}

void loop() {
  request req;
  vtr = "";
  memset(vtrCache, 0, sizeof vtrCache);
  memset(msgString, 0, sizeof msgString);

  // Added 6/12 for reading AUX voltage, no message is being sent via bt
  int value;
  float volt;
  bool auxWarning;

  bool extendedFrame = false;
  if (!digitalRead(CAN0_INT))  // If CAN0_INT pin is low, read receive buffer
  {
    CAN0.readMsgBuf(&rxId, &len, rxBuf);  // Read data: len = data length, buf = data byte(s)

    if (rxId == 0x8) {
      int count = 0;
      while (count < 50) {
        // Checksum add 8 to BroadcastID
        uint32_t checksum = 16;
        bool valid = true;
        String batMsg = "r";
        sprintf(msgString, "");
        for (byte i = 0; i < len; i++) {
          if (i < len - 1) checksum += rxBuf[i];
          else {
            checksum &= 0xff;
            if (checksum != rxBuf[i]) valid = false;
          }
          switch (i) {
            case 0:
            case 1:
            case 5:
              sprintf(msgString, "!%.2X", rxBuf[i]);
              break;
            case 3:
              // Shunting is bit 16
              sprintf(msgString, "!%.1X!%.2X", rxBuf[i] & 0x80, rxBuf[i]);
              break;
            case 2:
            case 4:
            case 6:
              sprintf(msgString, "%.2X", rxBuf[i]);
              break;
            case 7:
              sprintf(msgString, "");
              break;
          }
          batMsg += msgString;
        }
        if (valid) {
          Serial.println(batMsg);
          Serial.flush();
        }
        count++;
      }
    } else if (rxId == 0x289 || rxId == 0x288) {
      int count = 0;
      do {
        for (byte i = 0; i < len; i++) {
          // Delineates between 286 msg and 287
          if (i == 0 && rxId == 0x289) sprintf(vtrCache, "G%.2X", rxBuf[i]);
          else if ((i == 2 || i == 4 || i == 6) && rxId == 0x289) sprintf(vtrCache, "%.2X", rxBuf[i]);
          else if (i != 0 && rxId == 0x289) sprintf(vtrCache, "-%.2X", rxBuf[i]);
          else if (rxId == 0x288 && i == 0) sprintf(msgString, "I%.2X", rxBuf[i]);
          else if (rxId == 0x288 && (i == 1 || i == 2)) sprintf(msgString, "%.2X", rxBuf[i]);
          else if (rxId == 0x288 && i > 2) sprintf(msgString, "");
          else sprintf(msgString, "%.2X", rxBuf[i]);
          if (rxId != 0x289) Serial.print(msgString);
          else if (count == 1) vtr += vtrCache;
        }
        if (rxId != 0x289) {
          Serial.println();
          Serial.flush();
        }
        count++;
      } while ((rxId == 0x289 || rxId == 0x287) && count < 10);
    }
  }

  if (Serial.available() > 0) {
    char str[80];
    memset(str, 0, 80);
    int i = 0;
    while (Serial.peek() > 0) {
      if (Serial.peek() >= 'a' && Serial.peek() <= 'z') {
        str[i++] = Serial.read();
      } else {
        if (Serial.read() == '#') {
          break;
        }
      }
    }
    str[i] = 0;
    String faultrequest = "";
    if (i) {
      byte at = 0;
      const char *p = str;
      while (*p++) {
        faultrequest.concat(str[at++]);
        if (faultrequest.equals("upc")) {
          req = UPC;
          break;
        } else if (faultrequest.equals("ptc")) {
          req = PTC;
          break;
        } else if (faultrequest.equals("ctc")) {
          req = CTC;
          break;
        } else if (faultrequest.equals("vtr")) {
          if (vtr != "")
            for (int i = 0; i < 30; i++) {
              Serial.println(vtr);
              Serial.flush();
            }
          break;
        }
      }
      faultrequest = "";
      //if (debug) Serial.println(faultrequest);
      // OBD2 length, MOD, PID
      INT32U id = 0x750;
      INT8U canLen = 8;
      byte OBD2Len = 0;
      byte Mod = 0;
      byte PID_1 = 0;
      byte PID_2 = 0;
      byte PID_3 = 0;
      byte PID_4 = 0;
      byte PID_5 = 0;
      byte PID_6 = 0;

      String reqType;
      switch (req) {
        case UPC:
          OBD2Len = 4;
          Mod = 0x22;
          PID_1 = 0xF0;
          PID_2 = 0x0C;
          reqType = "UPC";
          break;
        case PTC:
          OBD2Len = 1;
          Mod = 0x07;
          reqType = "PTC";
          break;
        case CTC:
          OBD2Len = 1;
          Mod = 0x03;
          reqType = "CTC";
          break;
      }
      byte obdmsg[8] = { OBD2Len, Mod, PID_1, PID_2, PID_3, PID_4, PID_5, PID_6 };
      int count = 0;
      if (CAN0.sendMsgBuf(id, canLen, obdmsg) == CAN_OK) {
        int count = 0;
        while (!(rxId > 0x700) && count < 50) {
          CAN0.readMsgBuf(&rxId, &len, rxBuf);
          count++;
        }
        int obd2Length;
        if (rxBuf[1] == 98) {
          // Checking the parity
          if (rxBuf[4] & 0x80) {
            rxBuf[4] = ~rxBuf[4];
            rxBuf[5] = ~rxBuf[5];
            unsigned int current = int(rxBuf[4] + rxBuf[5]);
            current++;
            sprintf(msgString, "kN%.4X", current);
          } else {
            // It's positive
            sprintf(msgString, "kP%.2X%.2X", rxBuf[4], rxBuf[5]);
          }
          for (int i = 0; i < 30; i++) {
            Serial.println(msgString);
            Serial.flush();
          }
        } else if (rxBuf[1] == 67 || rxBuf[2] == 67) {
          for (int i = 0; i < 25; i++) {
            if (rxBuf[0] == 16) {
              obd2Length = rxBuf[1] - 2;
              sprintf(msgString, "C_%d_%.2X%.2X!%.2X%.2X!", obd2Length, rxBuf[4], rxBuf[5], rxBuf[6], rxBuf[7]);
              Serial.print(msgString);
              Serial.flush();
              obd2Length -= 4;
              // ISO-15765 Flow Control Response
              byte obdmsg[8] = { 0x30, 0, 0, 0, 0, 0, 0, 0 };
              while (!CAN0.sendMsgBuf(0x7E3, 8, obdmsg)) {}
              int upper = ceil(obd2Length / 7);
              for (int i = 0; i < upper; i++) {
                do {
                  CAN0.readMsgBuf(&rxId, &len, rxBuf);
                } while (rxId != 0x7EB && rxBuf[0] != 0x21 + i);
                int count = 7;
                int j = 0;
                while (obd2Length != 0 && count != 0) {
                  sprintf(msgString, "%.2X", rxBuf[j++]);
                  Serial.print(msgString);
                  Serial.flush();
                  obd2Length--;
                  count--;
                }
              }
            } else {
              obd2Length = rxBuf[0];

              sprintf(msgString, "C_%d_", rxBuf[2]);
              Serial.print(msgString);
              Serial.flush();
              obd2Length /= 2;
              int offset = 3;
              while (obd2Length > 0) {
                sprintf(msgString, "%.2X%.2X!", rxBuf[offset], rxBuf[offset + 1]);
                Serial.print(msgString);
                Serial.flush();
                obd2Length -= 2;
                offset += 2;
              }
            }
            Serial.println();
            Serial.flush();
          }
        } else if (rxBuf[1] == 71 || rxBuf[2] == 71) {
          for (int i = 0; i < 10; i++) {
            if (rxBuf[0] == 16) {
              obd2Length = rxBuf[1] - 2;
              sprintf(msgString, "P_%d_%.2X%.2X!%.2X%.2X!", obd2Length, rxBuf[4], rxBuf[5], rxBuf[6], rxBuf[7]);
              obd2Length -= 4;
              // ISO-15765 Flow Control Response
              byte obdmsg[8] = { 0x30, 0, 0, 0, 0, 0, 0, 0 };
              while (!CAN0.sendMsgBuf(0x7E3, 8, obdmsg)) {}
              int upper = ceil(obd2Length / 7);
              for (int i = 0; i < upper; i++) {
                do {
                  CAN0.readMsgBuf(&rxId, &len, rxBuf);
                } while (rxId != 0x7EB && rxBuf[0] != 0x21 + i);
                int count = 7;
                int j = 0;
                while (obd2Length != 0 && count != 0) {
                  sprintf(msgString, "%.2X", rxBuf[j++]);
                  obd2Length--;
                  count--;
                }
              }
            } else {
              obd2Length = rxBuf[0];

              sprintf(msgString, "P_%d_", rxBuf[2]);
              Serial.print(msgString);
              Serial.flush();
              obd2Length /= 2;
              int offset = 3;
              while (obd2Length > 0) {
                sprintf(msgString, "%.2X%.2X!", rxBuf[offset], rxBuf[offset + 1]);
                Serial.print(msgString);
                Serial.flush();
                obd2Length -= 2;
                offset += 2;
              }
            }
            Serial.println();
            Serial.flush();
          }
        }
      } 
    }
  }
}

/*********************************************************************************************************
  END FILE
*********************************************************************************************************/