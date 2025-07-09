  Name(FWSD, Package(3) {
    0x0,
    0x0,
    0x0
  } )

  // EC_SVC_MANAGEMENT 330c1273-fde5-4757-9819-5b6539037502
  Method(TFWS, 0x0, Serialized) {  
    If(LEqual(\_SB.FFA0.AVAL,One)) {
      CreateDwordField(BUFF,0,STAT) // Out – Status for req/rsp
      CreateField(BUFF,128,128,UUID) // UUID of service
      CreateByteField(BUFF,32,CMDD) //  In – First byte of command
      CreateWordField(BUFF,32,FWS0)  // Out – FWVersion
      CreateByteField(BUFF,34,FWS1)  // Out – SecureState
      CreateByteField(BUFF,35,FWS2)  // Out – BootStatus

      Store(0x1, CMDD) // EC_CAP_GET_FW_STATE
      Store(ToUUID("330c1273-fde5-4757-9819-5b6539037502"), UUID)
      Store(Store(BUFF, \_SB_.FFA0.FFAC), BUFF)
      If(LEqual(STAT,0x0) ) // Check FF-A successful?
      {
        FWSD[0] = FWS0
        FWSD[1] = FWS1
        FWSD[2] = FWS2
      }
    }
    Return(FWSD)
  }

  // Call test API to send notification event
  Method(TNFY, 0x0, Serialized) {  
    If(LEqual(\_SB.FFA0.AVAL,One)) {
      CreateDwordField(BUFF,0,STAT) // Out – Status for req/rsp
      CreateField(BUFF,128,128,UUID) // UUID of service
      CreateByteField(BUFF,32,CMDD) //  In – First byte of command
  
      Store(4, CMDD) // EC_CAP_TEST_NFY
      Store(ToUUID("330c1273-fde5-4757-9819-5b6539037502"), UUID)
      Store(Store(BUFF, \_SB_.FFA0.FFAC), BUFF)
    }
  }

