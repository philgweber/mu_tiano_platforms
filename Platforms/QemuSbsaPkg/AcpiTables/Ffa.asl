Device(FFA0) {
  Name(_HID, "ARML0002")

  OperationRegion(AFFH, FFixedHw, 2, 144) 
  Field(AFFH, BufferAcc, NoLock, Preserve) { AccessAs(BufferAcc, 0x1), FFAC, 1152 }     
    

  Name(_DSD, Package() {
      ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"), //Device Prop UUID
      Package() {
        Package(2) {
          "arm-arml0002-ffa-ntf-bind",
          Package() {
              1, // Revision
              1, // Count of following packages
              Package () {
                     ToUUID("330c1273-fde5-4757-9819-5b6539037502"), // Service1 UUID
                     Package () {
                          0x01,     // NotifyID 1
                          0x02,     // NotifyID 2
                          0x05,     // Test notify event
                      }
              },
         }
      }
    }
  }) // _DSD()

  Method(_DSM, 0x4, NotSerialized)
  {
    // Arg0 - UUID
    // Arg1 - Revision
    // Arg2: Function Index
    //         0 - Query
    //         1 - Notify
    //         2 - binding failure
    //         3 - infra failure    
    // Arg3 - Data
  
    //
    // Device specific method used to query
    // configuration data. See ACPI 5.0 specification
    // for further details.
    //
    If(LEqual(Arg0, Buffer(0x10) {
        //
        // UUID: {7681541E-8827-4239-8D9D-36BE7FE12542}
        //
        0x1e, 0x54, 0x81, 0x76, 0x27, 0x88, 0x39, 0x42, 0x8d, 0x9d, 0x36, 0xbe, 0x7f, 0xe1, 0x25, 0x42
      }))
    {
      // Query Function
      If(LEqual(Arg2, Zero)) 
      {
        Return(Buffer(One) { 0x03 }) // Bitmask Query + Notify
      }
      
      // Notify Function
      If(LEqual(Arg2, One))
      {
        // Arg3 - Package {UUID, Cookie}
        Store(DeRefOf(Index(Arg3,1)), \_SB.ECT0.NEVT )
        // Test notify event
        If(LEqual(DeRefOf(Index(Arg3,1)), 0x5))
        {
          Notify(\_SB.ECT0, 0x20)
        }

        Return(Buffer(One) {0x0}) 
      }
    } Else {
      Return(Buffer(One) { 0x00 })
    }
  }

  Method(AVAL,0x0, Serialized)
  {
    Return(One)
  }
}