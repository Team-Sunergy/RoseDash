#include <TimeLib.h>
#include <SoftwareSerial.h>
#include <mcp_can.h>
#include <SPI.h>


SoftwareSerial Bluetooth(4, 5); // RX, TX
// digital pin 2 is the hall pin
int hall_pin = 7;
// set number of hall trips for RPM reading (higher improves accuracy)
float hall_thresh = 5.0;

long unsigned int rxId;
unsigned char len = 0;
unsigned char rxBuf[8];
char msgString[128];                        // Array to store serial string
int speedpin = 8;
const int VOL_PIN = A0;
#define CAN0_INT 2                              // Set INT to pin 2
MCP_CAN CAN0(10);                               // Set CS to pin 10

typedef enum {
  VOLTAGE, 
  UPC, 
  PTC, 
  CTC, 
  OTHER
} request;

void setup()
{
  Serial.begin(115200);
    Bluetooth.begin(9600);
    // make the hall pin an input:
  pinMode(hall_pin, INPUT);
  // Initialize MCP2515 running at 16MHz with a baudrate of 500kb/s and the masks and filters disabled.
  if(CAN0.begin(MCP_ANY, CAN_250KBPS, MCP_8MHZ) == CAN_OK) {
    //Serial.println("MCP2515 Initialized Successfully!");
    //Bluetooth.println("MCP2515 Initialized Successfully!");
  }
  else {
    //Serial.println("Error Initializing MCP2515...");
    //Bluetooth.println("Error Initializing MCP2515...");
  }
  
  CAN0.setMode(MCP_NORMAL);                     // Set operation mode to normal so the MCP2515 sends acks to received data.
  pinMode(VOL_PIN, INPUT);
  pinMode(CAN0_INT, INPUT);                            // Configuring pin for /INT input
  //Serial.println("MCP2515 Library Receive Example...");
  //Bluetooth.println("MCP2515 Library Receive Example...");
}

void loop()
{
  request req;

 // preallocate values for tach
  float hall_count = 1.0;
  float start = micros();
  bool on_state = false;
  // counting number of times the hall sensor is tripped
  // but without double counting during the same trip
  while(true){
    if (digitalRead(hall_pin)==0){
      if (on_state==false){
        on_state = true;
        hall_count+=1.0;
      }
    } else{
      on_state = false;
    }
    
    if (hall_count>=hall_thresh || micros() - start >= 1000000){
      break;
    }
  }
  
  float end_time = micros();
  float time_passed = ((end_time-start)/1000000.0);
  float rpm_val = (hall_count/time_passed)*60.0 / 5;
  int mph = ((5.7583 /*1.34*/ * rpm_val * 60) / 5280);
  //sprintf(speedmsg,"S%d",mph);
  String speedmsg = "ss";
  speedmsg += mph;
  for (int i = 0; i < 40; i++) {
    Serial.println(speedmsg);
    //Serial.println(speedmsg);
    Bluetooth.println(speedmsg);
  }
         // delay in between reads for stability

  // Added 6/12 for reading AUX voltage, no message is being sent via bt 
  int value;
  float volt;
  bool auxWarning;

  /*value = analogRead( VOL_PIN );
  volt = value * 5.0 / 1023.0;
  for (int i = 0; i < 20; i++) {
    Serial.println("V" + String(volt));
    Bluetooth.println("V" + String(volt));
  }*/
  
  bool extendedFrame = false;
  if(!digitalRead(CAN0_INT))                         // If CAN0_INT pin is low, read receive buffer
  {
    CAN0.readMsgBuf(&rxId, &len, rxBuf);      // Read data: len = data length, buf = data byte(s)

    //if((rxId & 0x80000000) == 0x80000000)     // Determine if ID is standard (11 bits) or extended (29 bits)
      //sprintf(msgString, "Extended ID: 0x%.8lX  DLC: %1d  Data:", (rxId & 0x1FFFFFFF), len);
    /*else if (rxId == 0x7EB || rxId == 0x7E3 || rxId == 0x8 || rxId == 0x286 || rxId == 0x287 || rxId == 0x288)*/
      ///sprintf(msgString, "Standard ID: 0x%.3lX       DLC: %1d  Data:", rxId, len);

    //Serial.print(msgString);
    //Bluetooth.print(msgString);*/
    
    if((rxId & 0x40000000) == 0x40000000){    // Determine if message is a remote request frame.
      //sprintf(msgString, " REMOTE REQUEST FRAME");
      //Serial.print(msgString);
    }
    if(rxId == 0x8){
        int count = 0;
        while (count < 50) {
          // Checksum add 8 to BroadcastID
          uint32_t checksum = 16;
          bool valid = true;
          String batMsg = "r";
          sprintf(msgString, "");
          for(byte i = 0; i<len; i++){
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
            Bluetooth.println(batMsg);
          }
          count++;
        }
      }
    else if(rxId == 0x289 /*|| rxId == 0x287*/ || rxId == 0x288) {
        int count = 0;
        do {
          String telMes = "";
        for(byte i = 0; i<len; i++){
             // Delineates between 286 msg and 287
            if (i == 0 && rxId == 0x289) sprintf(msgString, "G%.2X", rxBuf[i]);
            else if ((i == 2 || i == 4 || i == 6) && rxId == 0x289) sprintf(msgString, "%.2X", rxBuf[i]);
            else if (i != 0  && rxId == 0x289) sprintf(msgString, "-%.2X", rxBuf[i]);
            //else if (rxId == 0x287 && i == 0) sprintf(msgString, "k%.2X", rxBuf[i]);
            //else if (rxId == 0x287) sprintf(msgString, "%.2X", rxBuf[i]);
            else if (rxId == 0x288 && i == 0) sprintf(msgString, "I%.2X", rxBuf[i]);
            else if (rxId == 0x288 && (i == 1 || i == 2)) sprintf(msgString, "%.2X", rxBuf[i]);
            else if (rxId == 0x288 && i > 2) sprintf(msgString, "");
            else sprintf(msgString, "%.2X", rxBuf[i]);
            telMes += msgString;
        } 
        Serial.println(telMes);
        Bluetooth.println(telMes);
        count++;
        } while ((rxId == 0x289 || rxId == 0x287) && count < 10);
    }     
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
        if (faultrequest.equals("upc")){
          req = UPC;
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
      switch(req) {
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
      byte obdmsg[8] = {OBD2Len,Mod,PID_1,PID_2,PID_3,PID_4,PID_5,PID_6};
            //Serial.println(reqType + " Request Sending");
            int count = 0;
              if (CAN0.sendMsgBuf(id, canLen, obdmsg) == CAN_OK) {
                int count = 0;
                while (!(rxId > 0x700) && count < 50) {
                  CAN0.readMsgBuf(&rxId, &len, rxBuf); 
                  count++;
                }
        /*for(byte i = 0; i<len; i++){
              sprintf(msgString, " 0x%.2X", rxBuf[i]);
              Serial.print(msgString);
            }*/
      //Serial.println();
      int obd2Length;
      if (rxBuf[1] == 98) {
            // Checking the parity
            if (rxBuf[4] & 0x80){
              rxBuf[4] = ~rxBuf[4];
              rxBuf[5] = ~rxBuf[5];
              unsigned int current = int(rxBuf[4] + rxBuf[5]);
              current++;
              sprintf(msgString, "kN%.4X", current);  
            }
            else {
              // It's positive
              sprintf(msgString, "kP%.2X%.2X", rxBuf[4], rxBuf[5]);
            }
            for (int i = 0; i < 30; i++) {
              Serial.println(msgString);
              Bluetooth.println(msgString);
            }
      } 
      else if (rxBuf[1] == 67 || rxBuf[2] == 67) {
        for (int i = 0; i < 25; i++) {
        if (rxBuf[0] == 16) {
          obd2Length = rxBuf[1] - 2;
          sprintf(msgString, "C_%d_%.2X%.2X!%.2X%.2X!", obd2Length, rxBuf[4], rxBuf[5], rxBuf[6], rxBuf[7]);
          Serial.print(msgString);
          Bluetooth.print(msgString);
          obd2Length -= 4;
          // ISO-15765 Flow Control Response
          byte obdmsg[8] = {0x30,0,0,0,0,0,0,0};
          while(!CAN0.sendMsgBuf(0x7E3, 8, obdmsg)) {}
          int upper = ceil(obd2Length / 7);
          for (int i = 0; i < upper; i++) {
            do {
                  CAN0.readMsgBuf(&rxId, &len, rxBuf);
               } while(rxId != 0x7EB && rxBuf[0] != 0x21 + i);
                int count = 7;
                int j = 0;
                while (obd2Length != 0 && count != 0) {
                  sprintf(msgString, "%.2X", rxBuf[j++]);
                  Serial.print(msgString);
                  Bluetooth.print(msgString);
                  obd2Length--;
                  count--;  
                }
          }
        } else 
        {
          obd2Length = rxBuf[0];

            sprintf(msgString, "C_%d_", rxBuf[2]);
            Serial.print(msgString);
            Bluetooth.print(msgString);
            obd2Length /= 2;
            int offset = 3; 
            while (obd2Length > 0) {
              sprintf(msgString, "%.2X%.2X!", rxBuf[offset], rxBuf[offset + 1]);
              Serial.print(msgString);
              Bluetooth.print(msgString);
              obd2Length -= 2;
              offset += 2;

          }
        }
        Serial.println();
        Bluetooth.println();
        }
      } else if (rxBuf[1] == 71 || rxBuf[2] == 71) {
        for (int i = 0; i < 10; i++) {
        //Serial.print("P");
        //Bluetooth.print("P");
        if (rxBuf[0] == 16) {
          obd2Length = rxBuf[1] - 2;
          sprintf(msgString, "P_%d_%.2X%.2X!%.2X%.2X!", obd2Length, rxBuf[4], rxBuf[5], rxBuf[6], rxBuf[7]);
          //Serial.print(msgString);
          //Bluetooth.print(msgString);
          obd2Length -= 4;
          // ISO-15765 Flow Control Response
          byte obdmsg[8] = {0x30,0,0,0,0,0,0,0};
          while(!CAN0.sendMsgBuf(0x7E3, 8, obdmsg)) {}
          int upper = ceil(obd2Length / 7);
          for (int i = 0; i < upper; i++) {
            do {
                  CAN0.readMsgBuf(&rxId, &len, rxBuf);
               } while(rxId != 0x7EB && rxBuf[0] != 0x21 + i);
                int count = 7;
                int j = 0;
                while (obd2Length != 0 && count != 0) {
                  sprintf(msgString, "%.2X", rxBuf[j++]);
                  //Serial.print(msgString);
                  //Bluetooth.print(msgString);
                  obd2Length--;
                  count--;  
                }
          }
        } else 
        {
          obd2Length = rxBuf[0];

            sprintf(msgString, "P_%d_", rxBuf[2]);
            Serial.print(msgString);
            Bluetooth.print(msgString);
            obd2Length /= 2;
            int offset = 3; 
            while (obd2Length > 0) {
              sprintf(msgString, "%.2X%.2X!", rxBuf[offset], rxBuf[offset + 1]);
              Serial.print(msgString);
              Bluetooth.print(msgString);
              obd2Length -= 2;
              offset += 2;
            }

        }
        Serial.println();
        Bluetooth.println();
        }
      }
      //Serial.println();
      //Bluetooth.println();
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
