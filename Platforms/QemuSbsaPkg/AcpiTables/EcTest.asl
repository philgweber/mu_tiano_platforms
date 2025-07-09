//
// EC Test interface to load KMDF driver and map methods
//
Device (ECT0) {
  Name (_HID, "ETST0001")
  Name (_UID, 0x0)
  Name (_CCA, 0x0)

  Name(BUFF, Buffer(144){})   // Create buffer for send/recv data
  Name (NEVT, 0x1234) // Initialize to some default value 

  Method (_STA) {
    Return(0xf)
  }

  //#include "ec_async.asl"
  #include "FwManagement.asl"

} // Device (ECT0)

#include "Ffa.asl"
#include "Thermal.asl"
