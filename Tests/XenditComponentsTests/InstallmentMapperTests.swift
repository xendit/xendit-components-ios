import XCTest
@testable import XenditComponents

final class InstallmentMapperTests: XCTestCase {
    private let keys = [
        "installment_configuration.terms",
        "installment_configuration.interval",
        "installment_configuration.code"
    ]

    func testSwitchingToPlanWithoutCodeClearsStalePromoCode() {
        let mapper = InstallmentPlanFieldMapper()
        var props: ChannelProperties = [:]
        mapper.setValue("3|month|PROMO", into: &props, keys: keys)
        XCTAssertEqual(props[keys[2]], "PROMO")
        mapper.setValue("6|month|", into: &props, keys: keys)
        XCTAssertEqual(props[keys[2]] ?? "", "")
    }

    func testTwoKeyInstallmentPlanDoesNotTrap() throws {
        let field = SessionResponse.Channel.FormField(
            groupLabel: nil,
            label: "Installment",
            placeholder: "",
            type: .installmentPlan,
            channelProperty: .multiple([
                "installment_configuration.terms",
                "installment_configuration.interval"
            ]),
            required: false,
            span: 2,
            join: nil,
            initialValue: nil,
            disabled: nil,
            displayIf: nil,
            flags: nil
        )
        let values = ["installment_configuration.terms": "3"]
        let result = try XenditMapper.mapFormValues(
            formValues: values,
            fields: [field],
            publicKey: "",
            sessionId: ""
        )
        XCTAssertTrue(result.isEmpty)
    }
}
