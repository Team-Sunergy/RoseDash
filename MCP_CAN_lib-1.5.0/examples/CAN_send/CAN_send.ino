
// CAN Send Example

#include <mcp_can.h>
#include <SPI.h>

MCP_CAN CAN0(10);     // Set CS to pin 10

void setup()
{
  Serial.begin(115200);

  // Initialize MCP2515 running at 16MHz with a baudrate of 500kb/s and the masks and filters disabled.
  if(CAN0.begin(MCP_ANY, CAN_500KBPS, MCP_8MHZ) == CAN_OK) Serial.println("MCP2515 Initialized Successfully!");
  else Serial.println("Error Initializing MCP2515...");

  CAN0.setMode(MCP_NORMAL);   // Change to normal mode to allow messages to be transmitted
}

byte data[8];

void loop( ) {
  int i = 0;
<<<<<<< HEAD
    for ( ; i < 200; ++i) {
      if (i <= 100) {
      data[0] = i;
      data[1] = i;
      }
      else {
        data[1] = i;
      }
=======
  double z = 0;
    for ( ; i < 100; ++i) {
      
      data[0] = i;  // speedometer
      data[1] = i;  // state of charge
      data[2] = i;  // high cell (volt)
      data[3] = i;  // low cell (volt)
      data[4] = i;  // pack (volt)
      data[5] = i;  // Hi Cel (temp *C)
      data[6] = i;  // Current Draw
      data[7] = i;  // extra
      
>>>>>>> 3fdf25f15c430ae64d66f3849dda05424b61887d
      // send data:  ID = 0x100, Standard CAN Frame, Data length = 8 bytes, 'data' = array of data bytes to send
      byte sndStat = CAN0.sendMsgBuf(0x100, 0, 7, data);
      
      if (sndStat == CAN_OK) Serial.println("Message Sent Successfully!"); 
      else Serial.println("Error Sending Message...");

      delay(100);   // send data per 100ms  
      
    }

    for ( ; i > 0 ; --i ) {
      
      data[0] = i;  // speedometer
      data[1] = i;  // state of charge
      data[2] = i;  // high cell (volt)
      data[3] = i;  // low cell (volt)
      data[4] = i;  // pack (volt)
      data[5] = i;  // Hi Cel (temp *C)
      data[6] = i;  // Current Draw
      data[7] = i;  // extra
      
      
      // send data:  ID = 0x100, Standard CAN Frame, Data length = 8 bytes, 'data' = array of data bytes to send    
      byte sndStat = CAN0.sendMsgBuf(0x100, 0, 7, data);
      
      if (sndStat == CAN_OK) Serial.println("Message Sent Successfully!"); 
      else Serial.println("Error Sending Message..."); 

      delay(100);   // send data per 100ms   
    }  
}
      
/*********************************************************************************************************
  END FILE
*********************************************************************************************************/
