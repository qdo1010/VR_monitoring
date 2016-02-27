//
//  SurveyTask.swift
//  VR_Monitoring
//
//  Created by Sarada Symonds on 2/27/16.
//  Copyright (c) 2016 NU Enabling Engineering. All rights reserved.
//
import ResearchKit

public var SurveyTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    
    //add survey questions in swift
    let questQuestionStepTitle = "What is your quest?"
    let textChoices = [
        ORKTextChoice(text: "Create a ResearchKit App", value: 0),
        ORKTextChoice(text: "Seek the Holy Grail", value: 1),
        ORKTextChoice(text: "Find a shrubbery", value: 2)
    ]
    let questAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithStyle(.SingleChoice, textChoices: textChoices)
    let questQuestionStep = ORKQuestionStep(identifier: "TextChoiceQuestionStep", title: questQuestionStepTitle, answer: questAnswerFormat)
    steps += [questQuestionStep]
    
    let effortQuestionStepTitle = "How much effort did you feel you exerted today?"
    //let effortAnswerFormat: ORKScaleAnswerFormat = ORKAnswerFormat.choiceAnswer(10, 0, 1, 5)
    //let effortQuesetionStep = ORKQuestionStep(identifier: "ScaleQuestionStep", title: effortQuesetionStepTitle, answer: effortAnswerFormat)
    //steps += [effortQuesetionStep]
    
    //TODO: add summary step
    
    return ORKOrderedTask(identifier: "SurveyTask", steps: steps)
}
