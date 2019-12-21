import XCTest
@testable import GameOMatKit

final class GameOMatKitTests: XCTestCase {

    func testDataNoNegative(problems: MathProblemFromOperands, lowerBound: Int = 0) {
        for add1 in lowerBound..<100 {
            for add2 in lowerBound..<100 {
                let wrongAnswers = problems.wrongAnswers(operand1: add1, operand2: add2)
                XCTAssertNil(wrongAnswers.first { $0.prefix(1) == "-" })
            }
        }
    }

    func testDataOnlyWrong(problems: MathProblemFromOperands, lowerBound: Int = 0) {
        for add1 in lowerBound..<100 {
            for add2 in lowerBound..<100 {
                let correct = problems.correctAnswer(operand1: add1, operand2: add2)
                let wrongAnswers = problems.wrongAnswers(operand1: add1, operand2: add2)
                XCTAssertNil(wrongAnswers.first { $0 == correct })
            }
        }
    }

    func testAdditionDataNoNegative() {
        testDataNoNegative(problems: AdditionProblems())
    }

    func testAdditionDataOnlyWrong() {
        testDataOnlyWrong(problems: AdditionProblems())
    }

    func testMinusDataNoNegative() {
        testDataNoNegative(problems: MinusProblems())
    }

    func testMinusDataOnlyWrong() {
        testDataOnlyWrong(problems: MinusProblems())
    }

    func testMultiplicationDataNoNegative() {
        testDataNoNegative(problems: MultiplicationProblems(), lowerBound: 2)
    }

    func testMultiplicationDataOnlyWrong() {
        testDataOnlyWrong(problems: MultiplicationProblems(), lowerBound: 2)
    }

    func testDivisionDataNoNegative() {
        testDataNoNegative(problems: DivisionProblems(), lowerBound: 2)
    }

    func testDivisionDataOnlyWrong() {
        testDataOnlyWrong(problems: DivisionProblems(), lowerBound: 2)
    }

    static var allTests = [
        ("testAdditionDataNoNegative", testAdditionDataNoNegative),
        ("testAdditionDataOnlyWrong", testAdditionDataOnlyWrong),
        ("testMinusDataNoNegative", testMinusDataNoNegative),
        ("testMinusDataOnlyWrong", testMinusDataOnlyWrong),
        ("testMultiplicationDataNoNegative", testMultiplicationDataNoNegative),
        ("testMultiplicationDataOnlyWrong", testMultiplicationDataOnlyWrong),
        ("testDivisionDataNoNegative", testDivisionDataNoNegative),
        ("testDivisionDataOnlyWrong", testDivisionDataOnlyWrong),
    ]
}
