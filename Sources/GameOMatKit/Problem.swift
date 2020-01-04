//
//  Problem.swift
//  
//
//  Created by Louis Franco on 12/20/19.
//

import Foundation

public struct Problem {
    public let question: String
    public let answer: String

    public let wrongAnswers: Set<String>

    public init(question: String, answer: String, wrongAnswers: Set<String>) {
        self.question = question
        self.answer = answer
        self.wrongAnswers = wrongAnswers
    }
}

public protocol ProblemGenerator {
    var maxAnswerLength: Int { get }
    func getNextProblem() -> Problem
}
