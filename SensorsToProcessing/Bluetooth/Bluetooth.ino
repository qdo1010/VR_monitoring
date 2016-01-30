
/* Include the software serial port library */
#include <SoftwareSerial.h>
/* to communicate with the Bluetooth module's TXD pin */
#define BT_SERIAL_TX 10
/* to communicate with the Bluetooth module's RXD pin */
#define BT_SERIAL_RX 11
/* Initialise the software serial port */
SoftwareSerial BluetoothSerial(BT_SERIAL_TX, BT_SERIAL_RX);

void setup() {
/* Set the baud rate for the hardware serial port */
Serial.begin(115200);
/* Set the baud rate for the software serial port */
BluetoothSerial.begin(115200);
delay(1000);

// Should respond with OK
BluetoothSerial.print("AT");
waitForResponse();


// Should respond with its version
BluetoothSerial.print("AT+VERSION");
waitForResponse();

// Set pin to 1234
BluetoothSerial.print("AT+PIN1234");  
waitForResponse();

// Set the name to BLU
BluetoothSerial.print("AT+NAMEHM");
waitForResponse();

// Set baudrate from 9600 (default) to 57600
// * Note of warning * - many people report issues after increasing JY-MCU
// baud rate upwards from the default 9,600bps rate (e.g. 'AT+BAUD4')
// so you may want to leave this and not alter the speed!!
BluetoothSerial.print("AT+BAUD7");
waitForResponse();

Serial.println("Finished!");
}

// Function to pass BlueTooth output through to serial port output
void waitForResponse() {
delay(1000);
while (BluetoothSerial.available()) {
Serial.write(BluetoothSerial.read());
}
Serial.write("\n");
}

void loop() {
  // put your main code here, to run repeatedly:
BluetoothSerial.print("Hello World!");
}
