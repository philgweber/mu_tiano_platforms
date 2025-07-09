/** @file
  Contains root level name space objects for the platform

  Copyright (c) 2024, MediaTek Inc. All rights reserved.<BR>
  SPDX-License-Identifier: BSD-2-Clause-Patent

**/

// Skin temperature sensor
Device(TMP1) {
  Name(_HID, "MSFT000A")
  Name (_UID, 1)

  Name(BUFF, Buffer(144){})   // Create buffer for send/recv data

  Method (_TMP) {
    // Check to make sure FFA is available and not unloaded
    If(LEqual(\_SB.FFA0.AVAL,One)) {
      CreateDwordField(BUFF,0,STAT)  // Out – Status for req/rsp
      CreateField(BUFF,128,128,UUID) // UUID of service
      CreateByteField(BUFF,32,CMDD)  //  In – First byte of command
      CreateByteField(BUFF,33,TID1)  //  In – Thermal Zone identifier
      CreateDWordField(BUFF,32,TMPD) // Out – Temperature for TZ

      Store(0x1, CMDD) // EC_THM_GET_TMP
      Store(1,TID1)
      Store(ToUUID("31f56da7-593c-4d72-a4b3-8fc7171ac073"), UUID) // Thermal
      Store(Store(BUFF, \_SB_.FFA0.FFAC), BUFF)

      If(LEqual(STAT,0x0) ) // Check FF-A successful?
      {
        Return (TMPD)
      }
    }
    Return(Zero)
  }

  // Update Thresholds
  Method(STMP, 0x2, Serialized) {
    // Check to make sure FFA is available and not unloaded
    If(LEqual(\_SB.FFA0.AVAL,One)) {
      CreateDwordField(BUFF,0,STAT)  // Out – Status for req/rsp
      CreateField(BUFF,128,128,UUID) // UUID of service
      CreateByteField(BUFF,32,CMDD)  //  In – First byte of command
      CreateByteField(BUFF,33,TID1)  //  In – Thermal Zone identifier
      CreateDwordField(BUFF,34,THS1) // In – Timeout in ms
      CreateDwordField(BUFF,38,THS2) // In – Low threshold tenth Kelvin
      CreateDwordField(BUFF,42,THS3) // In – High threshold tenth Kelvin
      CreateDwordField(BUFF,32,THSD) // Out – Status from EC

      Store(0x2, CMDD) // EC_THM_SET_THRS
      Store(1,TID1)
      Store(0,THS1) // Timout in ms 0 ignore
      Store(Arg0,THS2) // Low Threshold
      Store(Arg1,THS3) // High Threshold
      Store(ToUUID("31f56da7-593c-4d72-a4b3-8fc7171ac073"), UUID) // Thermal
      Store(Store(BUFF, \_SB_.FFA0.FFAC), BUFF)

      If(LEqual(STAT,0x0) ) // Check FF-A successful?
      {
        Return (THSD)
      }
    }
    Return(Zero)
  }


  // Arg0 GUID
  //      1f0849fc-a845-4fcf-865c-4101bf8e8d79 - Temperature GUID
  // Arg1 Revision
  // Arg2 Function Index
  // Arg3 Function dependent
  Method(_DSM, 0x4, Serialized) {
    // Input Variable
    If(LEqual(ToUuid("1f0849fc-a845-4fcf-865c-4101bf8e8d79"),Arg0)) {
        Switch(Arg2) {
          Case(0) {
            // We support function 0,1
            Return (Buffer() {0x03, 0x00, 0x00, 0x00})
          }
          // Update Thresholds
          // Arg3 = Package () { LowTemp, HighTemp }
          Case(1) {
            Return(STMP(DeRefOf(Index(Arg3,0)),DeRefOf(Index(Arg3,1)))) // MinRPM
          }
        }
    }

    Return (Ones)
  }

}

// MPTFCore Driver
Device(MPC0) {
  Name(_HID, "MSFT000D")
  Name (_UID, 1)
}

// MPTF Signal IO Client driver
Device(MPSI) {
  Name(_HID, "MSFT0011")
  Name (_UID, 1)
}

Device(CIO1) {
  Name(_HID, "MSFT000B")
  Name (_UID, 1)
  
  Name(BUFF, Buffer(144){})   // Create buffer for send/recv data

  // Arg0 Instance ID
  // Arg1 UUID of variable
  // Return (Status,Value)
  Method(GVAR,2,Serialized) {
    If(LEqual(\_SB_.FFA0.AVAL,One)) {
      CreateDwordField(BUFF,0,STAT)  // Out – Status for req/rsp
      CreateField(BUFF,128,128,UUID) // UUID of service
      CreateByteField(BUFF,32,CMDD)  //  In – First byte of command
      CreateByteField(BUFF,33,INST)  //  In – Thermal Zone identifier
      CreateWordField(BUFF,34,VLEN)  //  In - Variable length
      CreateField(BUFF,288,128,VUID) //  In - UUID or variable to read
      CreateDWordField(BUFF,32,RVAL) // Out – Return status

      Store(ToUUID("31f56da7-593c-4d72-a4b3-8fc7171ac073"), UUID)
      Store(0x5, CMDD) // EC_THM_GET_VAR
      Store(Arg0,INST) // Save instance ID
      Store(4,VLEN) // Variable is always DWORD here
      Store(Arg1, VUID)
      Store(Store(BUFF, \_SB_.FFA0.FFAC), BUFF)
      If(LEqual(STAT,0x0) ) // Check FF-A successful?
      {
        Return (RVAL)
      }
    }
    Return (Ones)
  }

  // Arg0 Instance ID
  // Arg1 UUID of variable
  // Return (Status,Value)
  Method(SVAR,3,Serialized) {
    If(LEqual(\_SB_.FFA0.AVAL,One)) {

      CreateDwordField(BUFF,0,STAT)  // Out – Status for req/rsp
      CreateField(BUFF,128,128,UUID) // UUID of service
      CreateByteField(BUFF,32,CMDD)  //  In – First byte of command
      CreateByteField(BUFF,33,INST)  //  In – Thermal Zone identifier
      CreateWordField(BUFF,34,VLEN)  //  In - Variable length
      CreateField(BUFF,288,128,VUID) //  In - UUID or variable to read
      CreateDwordField(BUFF,52,DVAL) //  In - Data value to write
      CreateDwordField(BUFF,32,RVAL) // Out – Return status
    
      Store(ToUUID("31f56da7-593c-4d72-a4b3-8fc7171ac073"), UUID)
      Store(0x6, CMDD) // EC_THM_SET_VAR
      Store(Arg0,INST) // Save instance ID
      Store(4,VLEN) // Variable is always DWORD here
      Store(Arg1, VUID)
      Store(Arg2,DVAL)
      Store(Store(BUFF, \_SB_.FFA0.FFAC), BUFF)
      If(LEqual(STAT,0x0) ) // Check FF-A successful?
      {
        Return (RVAL)
      }
    }
    Return (Ones)
  }


  // Arg0 GUID
  //      07ff6382-e29a-47c9-ac87-e79dad71dd82 - Input
  //      d9b9b7f3-2a3e-4064-8841-cb13d317669e - Output
  // Arg1 Revision
  // Arg2 Function Index
  // Arg3 Function dependent
  Method(_DSM, 0x4, Serialized) {
    // Input Variable
    If(LEqual(ToUuid("07ff6382-e29a-47c9-ac87-e79dad71dd82"),Arg0)) {
        Switch(Arg2) {
          Case(0) {
            // We support function 0-3
            Return (Buffer() {0x0f, 0x00, 0x00, 0x00})
          }
          Case(1) {
            Return(GVAR(1,ToUuid("db261c77-934b-45e2-9742-256c62badb7a"))) // MinRPM
          }
          Case(2) {
            Return(GVAR(1,ToUuid("5cf839df-8be7-42b9-9ac5-3403ca2c8a6a"))) // MaxRPM
          }
          Case(3) {
            Return(GVAR(1,ToUuid("adf95492-0776-4ffc-84f3-b6c8b5269683"))) // CurrentRPM
          }
        }
        Return(Ones)
    }
    // Output Variable
    If(LEqual(ToUuid("d9b9b7f3-2a3e-4064-8841-cb13d317669e"),Arg0)) {
        Switch(Arg2) {
          Case(0) {
            // We support function 0-3
            Return (Buffer() {0x0f, 0x00, 0x00, 0x00})
          }
          Case(1) {
            Return(SVAR(1,ToUuid("db261c77-934b-45e2-9742-256c62badb7a"),Arg3)) // MinRPM
          }
          Case(2) {
            Return(SVAR(1,ToUuid("5cf839df-8be7-42b9-9ac5-3403ca2c8a6a"),Arg3)) // MaxRPM
          }
          Case(3) {
            Return(SVAR(1,ToUuid("adf95492-0776-4ffc-84f3-b6c8b5269683"),Arg3)) // CurrentRPM
          }
        }
        Return(Ones)
    }

    Return (Ones)
  }

}
