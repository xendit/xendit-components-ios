import XCTest
@testable import XenditComponents

final class ValidationTests: XCTestCase {

    // MARK: - Email Validation

    func testValidEmail() {
        XCTAssertEqual(FormValidator.validateEmail("user@example.com"), .valid)
        XCTAssertEqual(FormValidator.validateEmail("user.name+tag@domain.co.uk"), .valid)
        XCTAssertEqual(FormValidator.validateEmail("user@subdomain.example.com"), .valid)
    }

    func testInvalidEmail() {
        XCTAssertNotEqual(FormValidator.validateEmail("notanemail"), .valid)
        XCTAssertNotEqual(FormValidator.validateEmail("missing@tld"), .valid)
        XCTAssertNotEqual(FormValidator.validateEmail("@nodomain.com"), .valid)
        XCTAssertNotEqual(FormValidator.validateEmail("spaces in@email.com"), .valid)
    }

    // MARK: - Phone Number Validation

    func testValidPhoneNumbers() {
        XCTAssertEqual(FormValidator.validatePhoneNumber("+628123456789"), .valid)
        XCTAssertEqual(FormValidator.validatePhoneNumber("+14155552671"), .valid)
        XCTAssertEqual(FormValidator.validatePhoneNumber("+66812345678"), .valid)
    }

    func testInvalidPhoneNumbers() {
        XCTAssertNotEqual(FormValidator.validatePhoneNumber("08123456789"), .valid)
        XCTAssertNotEqual(FormValidator.validatePhoneNumber("+"), .valid)
        XCTAssertNotEqual(FormValidator.validatePhoneNumber("notaphone"), .valid)
        XCTAssertNotEqual(FormValidator.validatePhoneNumber(""), .valid)
    }

    // MARK: - Postal Code Validation

    func testValidPostalCodes() {
        XCTAssertEqual(FormValidator.validatePostalCode("12345"), .valid)
        XCTAssertEqual(FormValidator.validatePostalCode("SW1A 1AA"), .valid)
        XCTAssertEqual(FormValidator.validatePostalCode("10001-0000"), .valid)
    }

    func testInvalidPostalCodes() {
        XCTAssertNotEqual(FormValidator.validatePostalCode("---"), .valid)
        XCTAssertNotEqual(FormValidator.validatePostalCode("   "), .valid)
    }

    // MARK: - Text Validation

    func testTextLengthValidation() {
        let field = makeTextField(required: true, minLength: 5, maxLength: 10)
        XCTAssertNotEqual(FormValidator.validate(field: field, value: "hi"), .valid)
        XCTAssertEqual(FormValidator.validate(field: field, value: "hello"), .valid)
        XCTAssertNotEqual(FormValidator.validate(field: field, value: "hello world!!"), .valid)
    }

    func testTextRegexValidation() {
        let field = makeTextField(
            required: true,
            regexValidators: [.init(regex: "^[0-9]+$", message: "Only numbers allowed")]
        )
        XCTAssertNotEqual(FormValidator.validate(field: field, value: "abc123"), .valid)
        XCTAssertEqual(FormValidator.validate(field: field, value: "12345"), .valid)
    }

    // MARK: - Required Field Validation

    func testRequiredFieldWithEmptyValue() {
        let field = makeTextField(required: true)
        let result = FormValidator.validate(field: field, value: "")
        XCTAssertNotEqual(result, .valid)
    }

    func testOptionalFieldWithEmptyValue() {
        let field = makeTextField(required: false)
        let result = FormValidator.validate(field: field, value: "")
        XCTAssertEqual(result, .valid)
    }

    // MARK: - Full Form Validation

    func testChannelPropertiesValid() {
        let field = makeTextField(required: true)
        let properties: ChannelProperties = ["account_number": "12345"]
        let isValid = FormValidator.channelPropertiesAreValid(
            fields: [field],
            channelProperties: properties,
            sessionType: .pay
        )
        XCTAssertTrue(isValid)
    }

    func testChannelPropertiesInvalidWhenRequired() {
        let field = makeTextField(required: true)
        let properties: ChannelProperties = [:]
        let isValid = FormValidator.channelPropertiesAreValid(
            fields: [field],
            channelProperties: properties,
            sessionType: .pay
        )
        XCTAssertFalse(isValid)
    }

    // MARK: - Helpers

    private func makeTextField(
        required: Bool,
        minLength: Int? = nil,
        maxLength: Int = 20,
        regexValidators: [SessionResponse.Channel.FormField.FieldType.RegexValidator]? = nil
    ) -> SessionResponse.Channel.FormField {
        SessionResponse.Channel.FormField(
            groupLabel: nil,
            label: "Account Number",
            placeholder: "Enter account number",
            type: .text(minLength: minLength, maxLength: maxLength, numeric: nil, regexValidators: regexValidators),
            channelProperty: .single("account_number"),
            required: required,
            span: 2,
            join: nil,
            initialValue: nil,
            disabled: nil,
            displayIf: nil,
            flags: nil
        )
    }
}

