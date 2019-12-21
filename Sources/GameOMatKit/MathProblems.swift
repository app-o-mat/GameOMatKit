//
//  MathProblems.swift
//  
//
//  Created by Louis Franco on 12/20/19.
//

import Foundation

public enum MathOperator: String, CaseIterable {
    case add
    case minus
    case mult
    case div

    private func generator() -> ProblemGenerator {
        switch self {
        case .add:
            return AdditionProblems()
        case .minus:
            return MinusProblems()
        case .mult:
            return MultiplicationProblems()
        case .div:
            return DivisionProblems()
        }
    }

    public static func at(index: Int) -> MathOperator {
        return MathOperator.allCases[index]
    }

    public static func named(name: String?) -> MathOperator? {
        MathOperator.allCases.first { $0.rawValue == name }
    }

    public func index() -> Int {
        return MathOperator.allCases.firstIndex(of: self) ?? 0
    }

    public func getNextProblem() -> Problem {
        return generator().getNextProblem()
    }
}

public class AdditionProblems: ProblemGenerator, MathProblemFromOperands {
    public let smallestOperand = 0
    public let biggestOperand = 10

    public func question(operand1: Int, operand2: Int) -> String {
        return "\(operand1) + \(operand2)"
    }

    public func correctAnswer(operand1: Int, operand2: Int) -> String {
        return "\(operand1 + operand2)"
    }

    public func wrongAnswers(operand1: Int, operand2: Int) -> Set<String> {
        let sum = operand1 + operand2
        var wrongAnswers = [
            "\(sum + 1)",
            "\(sum + 2)",
            "\(sum + 3)",
            "\(sum + operand1)", "\(sum + operand2)",
            "\(sum - operand1)", "\(sum - operand2)",
            "\(operand1 * operand2)",
        ]

        if sum >= 1 {
            wrongAnswers.append("\(sum - 1)")
            if sum >= 2 {
                wrongAnswers.append("\(sum - 2)")
                if sum >= 3 {
                    wrongAnswers.append("\(sum - 3)")
                }
            }
        }

        wrongAnswers.removeAll { "\(sum)" == $0 }
        return Set(wrongAnswers)
    }

}

public class MinusProblems: ProblemGenerator, MathProblemFromOperands {
    public let smallestOperand = 0
    public let biggestOperand = 10

    public func question(operand1: Int, operand2: Int) -> String {
        return "\(operand1 + operand2) - \(operand2)"
    }

    public func correctAnswer(operand1: Int, operand2: Int) -> String {
        return "\(operand1)"
    }

    public func wrongAnswers(operand1: Int, operand2: Int) -> Set<String> {
        var wrongAnswers = [
            "\(operand1 + 1)", "\(operand2)",
            "\(operand1 + 2)",
        ]

        if operand1 >= 1 {
            wrongAnswers.append("\(operand1 - 1)")
            if operand1 >= 2 {
                wrongAnswers.append("\(operand1 - 2)")
            }
        }

        wrongAnswers.removeAll { "\(operand1)" == $0 }
        return Set(wrongAnswers)
    }
}

public class MultiplicationProblems: ProblemGenerator, MathProblemFromOperands {
    public let smallestOperand = 2
    public let biggestOperand = 12

    public func question(operand1: Int, operand2: Int) -> String {
        return "\(operand1) × \(operand2)"
    }

    public func correctAnswer(operand1: Int, operand2: Int) -> String {
        return "\(operand1 * operand2)"
    }

    public func wrongAnswers(operand1: Int, operand2: Int) -> Set<String> {
        let product = operand1 * operand2
        var wrongAnswers = [
            "\(product + 1)", "\(product - 1)",
            "\(product + 2)", "\(product - 2)",
            "\(product + 3)", "\(product - 3)",
            "\(product + operand1)", "\(product + operand2)",
            "\(product - operand1)", "\(product - operand2)",
            "\(operand1 + operand2)",
        ]

        wrongAnswers.removeAll { "\(product)" == $0 }

        return Set(wrongAnswers)
    }
}

public class DivisionProblems: ProblemGenerator, MathProblemFromOperands {
    public let smallestOperand = 2
    public let biggestOperand = 12

    public func question(operand1: Int, operand2: Int) -> String {
        return "\(operand1 * operand2) ÷ \(operand2)"
    }

    public func correctAnswer(operand1: Int, operand2: Int) -> String {
        return "\(operand1)"
    }

    public func wrongAnswers(operand1: Int, operand2: Int) -> Set<String> {
        let product = operand1 * operand2
        var wrongAnswers = [
            "\(operand1 + 1)", "\(operand1 - 1)",
            "\(operand1 + 2)", "\(operand1 - 2)",
            "\(product - operand2)",
        ]

        wrongAnswers.removeAll { "\(operand1)" == $0 }
        return Set(wrongAnswers)
    }
}
