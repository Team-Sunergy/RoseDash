#include <SoftwareSerial.h>
#include <mcp_can.h>
#include <SPI.h>

SoftwareSerial Bluetooth(4, 5); // RX, TX

long unsigned int rxId;
unsigned char len = 0;
unsigned char rxBuf[8];
char msgString[128];                        // Array to store serial string
int speedpin = 8;
#define CAN0_INT 2                              // Set INT to pin 2
MCP_CAN CAN0(10);                               // Set CS to pin 10

typedef enum {
  VOLTAGE, 
  SOC, 
  PTC, 
  CTC, 
  OTHER
} request;

void setup()
{
  Serial.begin(115200);
    Bluetooth.begin(9600);
  // Initialize MCP2515 running at 16MHz with a baudrate of 500kb/s and the masks and filters disabled.
  if(CAN0.begin(MCP_ANY, CAN_500KBPS, MCP_8MHZ) == CAN_OK) {
    //Serial.println("MCP2515 Initialized Successfully!");
    //Bluetooth.println("MCP2515 Initialized Successfully!");
  }
  else {
    //Serial.println("Error Initializing MCP2515...");
    //Bluetooth.println("Error Initializing MCP2515...");
  }
  
  CAN0.setMode(MCP_NORMAL);                     // Set operation mode to normal so the MCP2515 sends acks to received data.

  pinMode(CAN0_INT, INPUT);                            // Configuring pin for /INT input
  pinMode(speedpin, INPUT);
  //Serial.println("MCP2515 Library Receive Example...");
  //Bluetooth.println("MCP2515 Library Receive Example...");
}

void loop()
{
  char mphstring[128]; 
  request req;
  unsigned long rotationsInASecond = 0;
  unsigned long durationA = 0;
  unsigned long durationB = 0;
  //unsigned long durationC = 0;
  //unsigned long durationD = 0;
  bool accurateReading;
  /*while (durationA < 1000) {
    //accurateReading = true;
    //durationD = durationA;
    for (int i = 0; i < 16; i++) {
      //durationC = durationA;
      durationA += pulseIn(speedpin,HIGH, 10);
      /*if (durationC == durationA) {
        accurateReading = false;
        break;  
      }
    }
    //if (!accurateReading) durationA = durationD;
    if (durationA != durationB /*&& accurateReading) {
      rotationsInASecond++;
      durationB = durationA;
    }
  }
  if (rotationsInASecond > 0) {
    rotationsInASecond *= 1000;
  sprintf(mphstring, "rotations in a second is %d ", rotationsInASecond);
  Serial.println(mphstring);
  }
  if (rotationsInASecond > 0) {
    unsigned long rpm = rotationsInASecond / 60;
    // Rose's revolutional distance is ~5.7583 ft //
    unsigned long mph = (5.7583 * rpm * 60 / 5280); 
    
    sprintf(mphstring, "%d mph rpm: %d", mph, rpm);
    Serial.println(mphstring);
  }*/
  bool extendedFrame = false;
  if(!digitalRead(CAN0_INT))                         // If CAN0_INT pin is low, read receive buffer
  {
    CAN0.readMsgBuf(&rxId, &len, rxBuf);      // Read data: len = data length, buf = data byte(s)

    if((rxId & 0x80000000) == 0x80000000)     // Determine if ID is standard (11 bits) or extended (29 bits)
      sprintf(msgString, "Extended ID: 0x%.8lX  DLC: %1d  Data:", (rxId & 0x1FFFFFFF), len);
    else /*if (rxId == 0x7EB || rxId == 0x7E3 || rxId == 0x8 || rxId == 0x286 || rxId == 0x287 || rxId == 0x288)*/
      sprintf(msgString, "Standard ID: 0x%.3lX       DLC: %1d  Data:", rxId, len);

    //Serial.print(msgString);
    //Bluetooth.print(msgString);*/
    
    if((rxId & 0x40000000) == 0x40000000){    // Determine if message is a remote request frame.
      sprintf(msgString, " REMOTE REQUEST FRAME");
      //Serial.print(msgString);
    } else if(rxId == 0x286 || rxId == 0x287 || rxId == 0x288) {
        for(byte i = 0; i<len; i++){
             // Delineates between 286 msg and 287
            if (i == 0 && rxId == 0x286) sprintf(msgString, "G%.2X", rxBuf[i]);
            else if ((i == 2 || i == 4 || i == 6) && rxId == 0x286) sprintf(msgString, "%.2X", rxBuf[i]);
            else if (i != 0  && rxId == 0x286) sprintf(msgString, "-%.2X", rxBuf[i]);
            else if (rxId == 0x287 && i == 0) sprintf(msgString, "H%.2X", rxBuf[i]);
            else if (rxId == 0x287) sprintf(msgString, "%.2X", rxBuf[i]);
            else if (rxId == 0x288 && i == 0) sprintf(msgString, "I%.2X", rxBuf[i]);
            else if (rxId == 0x288) sprintf(msgString, "%.2X", rxBuf[i]);
            else sprintf(msgString, "%.2X", rxBuf[i]);
            Bluetooth.print(msgString);
            Serial.print(msgString);
        } 
        Serial.println();
        Bluetooth.println();
    } else if (rxId == 0x7EB /*|| rxId == 0x7E3 */|| rxId == 0x8) {
        delay(50);
        int count = 0;
        int obd2Length = 0;
        
              /*String s1 = "\n\nrxBuf[";
              String s2 = String(i);
              String s3 = "] == ";
              String s4 = String(rxBuf[i]);
              String s5 = s1 + s2 + s3 + s4 + "\n\n";*/
              if (rxBuf[1] == 67 || rxBuf[2] == 67) {
                sprintf(msgString, "C");
                if (rxBuf[0] == 16) {
                  obd2Length = rxBuf[1] - 2;
                  sprintf(msgString, "C%d_%.2X%.2X%.2X%.2X", obd2Length, rxBuf[4], rxBuf[5], rxBuf[6], rxBuf[7]);
                  obd2Length -= 4;
                  // ISO-15765 Flow Control Response
                  byte obdmsg[8] = {0x30,0,0,0,0,0,0,0};
                  CAN0.sendMsgBuf(0x7E3, 8, obdmsg);
                  int upper = ceil(obd2Length / 7);
                  for (int i = 0; i < upper; i++) {
                    do {
                      CAN0.readMsgBuf(&rxId, &len, rxBuf);
                    } while(rxId != 0x7EB && rxBuf[0] != 0x21 + i);
                    int count = 7;
                    int j = 0;
                    char* msgDigest = "";
                    while (obd2Length != 0 && count != 0) {
                      sprintf(msgDigest, "%.2X", rxBuf[j++]);
                      strcat(msgString, msgDigest);
                      obd2Length--;
                      count--;  
                    }
                  }
                  Bluetooth.print(msgString);
                  Serial.print(msgString);  
                } else
                {
                  obd2Length = rxBuf[2] * 2;
                  sprintf(msgString, "C%d_", obd2Length);
                  obd2Length /= 2;
                  int i = 4;
                  char* msgDigest = "";
                  while (obd2Length != 0) {
                    sprintf(msgDigest, "%.2X%.2X", rxBuf[i++], rxBuf[i++]);
                    strcat(msgString, msgDigest);
                    obd2Length--;
                  }
                  Bluetooth.print(msgString);
                  Serial.print(msgString); 
                }
              }
                else if (rxBuf[1] == 71) {
                if (rxBuf[0] == 16) {
                  obd2Length = rxBuf[1] - 2;
                  sprintf(msgString, "P%d_%.2X%.2X%.2X%.2X", obd2Length, rxBuf[4], rxBuf[5], rxBuf[6], rxBuf[7]);
                  obd2Length -= 4;
                  // ISO-15765 Flow Control Response
                  byte obdmsg[8] = {0x30,0,0,0,0,0,0,0};
                  CAN0.sendMsgBuf(0x7E3, 8, obdmsg);
                  int upper = ceil(obd2Length / 7);
                  for (int i = 0; i < upper; i++) {
                    do {
                      CAN0.readMsgBuf(&rxId, &len, rxBuf);
                    } while(rxId != 0x7EB && rxBuf[0] != 0x21 + i);
                    int count = 7;
                    int j = 0;
                    char* msgDigest = "";
                    while (obd2Length != 0 && count != 0) {
                      sprintf(msgDigest, "%.2X", rxBuf[j++]);
                      strcat(msgString, msgDigest);
                      obd2Length--;
                      count--;  
                    }
                  }
                  Bluetooth.print(msgString);
                  Serial.print(msgString);  
                } else
                {
                  obd2Length = rxBuf[2] * 2;
                  sprintf(msgString, "P%d_", obd2Length);
                  obd2Length /= 2;
                  int i = 4;
                  char* msgDigest = "";
                  while (obd2Length != 0) {
                    sprintf(msgDigest, "%.2X%.2X", rxBuf[i++], rxBuf[i++]);
                    strcat(msgString, msgDigest);
                    obd2Length--;
                  }
                  Bluetooth.print(msgString);
                  Serial.print(msgString); 
                }
              }
      Serial.println();
      Bluetooth.println();
    }     
    delay(10); 
  }

  if (Bluetooth.available() > 0) {
    char str[80];
    memset(str, 0, 80);
    int i = 0;
    while(Bluetooth.peek() > 0) {
      if (Bluetooth.peek() >= 'a' && Bluetooth.peek() <= 'z') {
        //Serial.print((char)Bluetooth.read());
        str[i++] = Bluetooth.read();
      } else {
        if(Bluetooth.read() == '#') {
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
        if (faultrequest.equals("soc")){
          req = SOC;
          //Serial.println(faultrequest);
          break;
        }
        else if (faultrequest.equals("ptc")){
          req = PTC;
          //Serial.println(faultrequest);
          break;
        }
        else if (faultrequest.equals("ctc")){
          req = CTC;
          //Serial.println(faultrequest);
          break;
        }
      }
      faultrequest = "";
      //Serial.println(faultrequest);
      // OBD2 length, MOD, PID
      INT32U id = 0x7E3;
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
      switch(req) {
        case SOC:
          OBD2Len = 4;
          Mod = 0x22;
          PID_1 = 0xF0;
          PID_2 = 0xF;
          reqType = "SOC";
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
      byte obdmsg[8] = {OBD2Len,Mod,PID_1,PID_2,PID_3,PID_4,PID_5,PID_6};
            //Serial.println(reqType + " Request Sending");
            if (CAN0.sendMsgBuf(id, canLen, obdmsg) == CAN_OK) {
              //Serial.println("Message Sent Successfully!");
            } else {
              //Serial.println("Error Sending Message...");
            }
     }
    }
  }

/*********************************************************************************************************
  END FILE
*********************************************************************************************************/
