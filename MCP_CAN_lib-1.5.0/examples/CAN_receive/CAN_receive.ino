#include <SoftwareSerial.h>
#include <mcp_can.h>
#include <SPI.h>

SoftwareSerial Bluetooth(4, 5); // RX, TX

long unsigned int rxId;
unsigned char len = 0;
unsigned char rxBuf[8];
char msgString[128];                        // Array to store serial string

#define CAN0_INT 2                              // Set INT to pin 2
MCP_CAN CAN0(10);                               // Set CS to pin 10

enum request {VOLTAGE, OTHER};

void setup()
{
  Serial.begin(115200);
    Bluetooth.begin(9600);
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

  pinMode(CAN0_INT, INPUT);                            // Configuring pin for /INT input
  
  //Serial.println("MCP2515 Library Receive Example...");
  //Bluetooth.println("MCP2515 Library Receive Example...");
}

void loop()
{
  bool notOwn = true;
  if(!digitalRead(CAN0_INT))                         // If CAN0_INT pin is low, read receive buffer
  {
    CAN0.readMsgBuf(&rxId, &len, rxBuf);      // Read data: len = data length, buf = data byte(s)

    /*if((rxId & 0x80000000) == 0x80000000)     // Determine if ID is standard (11 bits) or extended (29 bits)
      //sprintf(msgString, "Extended ID: 0x%.8lX  DLC: %1d  Data:", (rxId & 0x1FFFFFFF), len);
    else
      //sprintf(msgString, "Standard ID: 0x%.3lX       DLC: %1d  Data:", rxId, len);

    //Serial.print(msgString);
    //Bluetooth.print(msgString);*/
    
    if((rxId & 0x40000000) == 0x40000000){    // Determine if message is a remote request frame.
      //sprintf(msgString, " REMOTE REQUEST FRAME");
      //Serial.print(msgString);
    } else if(rxId == 0x286 || rxId == 0x287) { 
        for(byte i = 0; i<len; i++){
             // Delineates between 286 msg and 287
            if ((i == 2 || i == 4 || i == 6) && rxId == 0x286) sprintf(msgString, "%.2X", rxBuf[i]);
            else if (i != 0  && rxId == 0x286) sprintf(msgString, "-%.2X", rxBuf[i]);
            else if (rxId == 0x287 && i == 0) sprintf(msgString, "G%.2X", rxBuf[i]);
            else if (rxId == 0x287) sprintf(msgString, "%.2X", rxBuf[i]);
            else sprintf(msgString, "%.2X", rxBuf[i]);
            Bluetooth.print(msgString);
            //Serial.print(msgString);
        }
        //Serial.println();
        Bluetooth.println();
        notOwn = false;
    } else if (rxId == 0x7EB) {
            for(byte i = 0; i<len; i++){
              sprintf(msgString, " 0x%.2X", rxBuf[i]);
              Serial.print(msgString);
            }
      Serial.println();
    }     
    delay(10); 
  }

  if (Bluetooth.available() > 0) {
    request req = OTHER;
    char str[80];
    memset(str, 0, 80);
    int i = 0;
    while(Bluetooth.peek() > 0 && notOwn) {
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
        if (faultrequest.equals("hello")){
          req = VOLTAGE;
          Serial.println(faultrequest);
          break;
        }
      }
      // OBD2 length, MOD, PID
      byte obdmsg[] = {0x04,0x22,0xf0,0x0f,0x00,0x00,0x00,0x00};
      switch(req) {
        case VOLTAGE:
          Serial.println("Voltage Request Sending");
          if (CAN0.sendMsgBuf(0x7E3, 8, obdmsg) == CAN_OK) {
            Serial.println("Message Sent Successfully!");
          } else {
            Serial.println("Error Sending Message...");
          }
          break;
            
      }
     }
    }
  }

/*********************************************************************************************************
  END FILE
*********************************************************************************************************/
