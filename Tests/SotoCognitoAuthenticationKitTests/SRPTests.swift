//===----------------------------------------------------------------------===//
//
// This source file is part of the Soto for AWS open source project
//
// Copyright (c) 2020-2024 the Soto project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Soto project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import BigNum
import Crypto
@testable import SotoCognitoAuthenticationSRP
@_spi(SotoInternal) import SotoSignerV4
import Testing

struct SRPTests {
    /// create SRP for testing
    func createTestSRP() -> SRP<SHA256> {
        let a = BigNum(hex:
            "37981750af33fdf93fc6dce831fe794aba312572e7c33472528" +
                "54e5ce7c7f40343f5ad82f9ad3585c8cb1184c54c562f8317fc" +
                "2924c6c7ade72f1e8d964f606e040c8f9f0b12e3fe6b6828202" +
                "a5e40ca0103e880531921e56de3acc410331b8e5ddcd0dbf249" +
                "bfa104f6b797719613aa50eabcdb40fd5457f64861dd71890eba")
        return SRP<SHA256>(a: a)
    }

    @Test
    func testSRPAValue() {
        let expectedA = BigNum(hex:
            "f93b917abccc667f4fac29d1e4c111bcd37d2c37577e7f113ad85030ec6" +
                "157c70dfee728ac4aee9a7631d85a68aec3ef72864b6e8a134f5c5eef89" +
                "40b93bb1db1ada9c1de770db282d644eeb3c551d35ce8de4d2cf98d0d79" +
                "9b6a7f1fe51568d11162ce0cded8246b630169dcfc2d5a43817d52f121b" +
                "3d75ab1a43dc30b7cec02e42e332d5fd781023d9c1fd44f3d1129d21155" +
                "0ce57c004aca95a367592705b517298f724e6314ffbac2425b2beb5095f" +
                "23b75dd3dd232adda700080d7a22a87383d3746d39f6427b7daf2a00683" +
                "038ff7dc099081b2bf43eb5e2e30465487dafb3cc875fdd9b475d46a0ac" +
                "1d07cf928fd11e06c5999596160168fc31228f7f3329d4b873acbf1540a" +
                "16418a3ee5a0a5070a3db558f5cf8cf15388ff0a6e4234bf1de3e5bade8" +
                "e4aa607d633a94a06bee4386c7444e06fd584282b9d576be318f0f20305" +
                "7e80996f79a2bb0a63ad4786d5cc12b1321bd6644e001cee194171f5b04" +
                "fcd65f3f280b6dadabae0401a9ae557ad27939730ce146319aa7f08d1e33")
        let srp = self.createTestSRP()
        #expect(expectedA == srp.A)
    }

    @Test
    func testSRPKey() {
        let B = BigNum(hex:
            "a0812a0ee3fa8484a73addeb6a9afa145cff1eca2a6b86537a5d15132d" +
                "5811dd088d16e7d581b2798229350e6e473503cebddf19cabd3f14fb34" +
                "50a6858bafc972a29702d8772a22b000a160812a7fe29bcac2c36d43b9" +
                "1c118224626c2f0782d70f79c82ac5183e0d7d8c7b23ad0bda1f4fba94" +
                "1998bfc82e46415e49026bb33f8271cb9a56e69f518e90bc2f4c42c7bb" +
                "27720e25a14dcfbb5176effb3069a2bc627f18ec07a3e4118f61402dda" +
                "56a6da3f331d8c2cf78513d767b2bf040809e5a334c7bb98cb720ef565" +
                "4100cfa57d21155fc7630654964370fd512b30febc6c61bfa3415c7266" +
                "0c5dad3444881d272c3abd7ecec0e483493b1491391bef4348d1c27be7" +
                "00e443301fc856a9d1b6ca36fdc46eec9f3c51f0ea566f5a85c87d395d" +
                "3d9fc2a594945a860841d5b328f1910058b2bb822ac976d961736fac42" +
                "e84b46074762de8b254f37260e3b1da88529dd1060ca52b2dc9de5d773" +
                "72b1d74ea111de406aac964993133a6f172e8fae54eb885e6a3cd774f1" +
                "ca6be98b6ddc35")!
        let salt = BigNum(hex: "8dbcb21f18ae3216")!.bytes
        let expectedKey = BigNum(hex: "b70fad71e9658b24b0ec678774ecca30")!.bytes

        let srp = self.createTestSRP()
        let key = srp.getPasswordAuthenticationKey(username: "poolidtestuser", password: "testpassword", B: B, salt: salt)

        #expect(key == expectedKey)
    }

    @Test
    func testHKDF() {
        let password = [UInt8]("password".utf8)
        let salt = [UInt8]("salt".utf8)
        let info = [UInt8]("HKDF key derivation".utf8)

        let sha1Result = SRP<Insecure.SHA1>.HKDF(seed: password, info: info, salt: salt, count: Insecure.SHA1.Digest.byteCount)
        #expect(sha1Result.hexDigest().uppercased() == "9912F20853DFF1AFA944E9B88CA63C410CBB1938")
        let sha256Result = SRP<SHA256>.HKDF(seed: password, info: info, salt: salt, count: 16)
        #expect(sha256Result.hexDigest().uppercased() == "398F838A6019FC27D99D90009A1FE0BF")
    }
}
