//
//  ReadWrite.swift
//  Shout
//
//  Created by Jake Heiser on 3/15/19.
//

import CSSH
import struct Foundation.Data

enum ReadWriteProcessor {

    enum DataResult {
        case data(Data)
        case len(Int)
    }

    enum ReadResult {
        case data(DataResult)
        case eagain
        case done
        case error(SSHError)
    }
    
    static func processRead(result: Int, buffer: inout [Int8], session: OpaquePointer) -> ReadResult {
        if result > 0 {
            let data = Data(buffer: UnsafeBufferPointer(start: &buffer, count: result))
            return .data(.data(data))
        } else if result == 0 {
            return .done
        } else if result == LIBSSH2_ERROR_EAGAIN {
            return .eagain
        } else {
            return .error(SSHError.codeError(code: Int32(result), session: session))
        }
    }

    static func processRead(result: Int, session: OpaquePointer) -> ReadResult {
        if result > 0 {
            return .data(.len(result))
        } else if result == 0 {
            return .done
        } else if result == LIBSSH2_ERROR_EAGAIN {
            return .eagain
        } else {
            return .error(SSHError.codeError(code: Int32(result), session: session))
        }
    }
    
    enum WriteResult {
        case written(Int)
        case eagain
        case error(SSHError)
    }
    
    static func processWrite(result: Int, session: OpaquePointer) -> WriteResult {
        if result >= 0 {
            return .written(result)
        } else if result == LIBSSH2_ERROR_EAGAIN {
            return .eagain
        } else {
            return .error(SSHError.codeError(code: Int32(result), session: session))
        }
    }
    
}
