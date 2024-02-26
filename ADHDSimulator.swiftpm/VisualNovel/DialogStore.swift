//
//  File.swift
//  
//
//  Created by Gabriel Medeiros Martins on 22/02/24.
//

import Foundation

class DialogStore: ObservableObject {
    var dialogs: [Dialog] = []
    
    let preExamDialogs: [Dialog] = [
        Dialog(
            moment: .A1,
            text: "\"Hi! My name is Gabriel and today I'm going to tell a bit about my school experience as a person diagnosticated with ADHD.\nDo you know what this word means?\"",
            options: [
                Dialog.Option(text: "Yes, I know a little about it.", leadsTo: .A2),
                Dialog.Option(text: "Oh, I don't know this word... What does it mean?", leadsTo: .A3),
            ]
        ),
        Dialog(
            moment: .A2,
            text: "\"You do? Cool! Do you want to know a little more about how is living with this condition in the school environment? I promise it is interesting!\"",
            options: [
                Dialog.Option(text: "Yes, please tell me more.", leadsTo: .A3),
                Dialog.Option(text: "It seems fun, but not right now. Thanks.", leadsTo: .Home),
            ]
        ),
        Dialog(
            moment: .A3,
            text: "\"ADHD stands for Attention-Deficit/Hyperactivity Disorder. It's a condition very common and it has a heavy impact on the day to day life, creating all sort of problems.\"",
            options: [
                Dialog.Option(text: "[...]", leadsTo: .A4),
            ]
        ),
        Dialog(
            moment: .A4,
            text: "\"I have forgotten to do my homework many many times and have gotten a lesser grade because of it. Some people call me lazy, but it's not like that.\nHas anyone ever told you how an ADHDer \"sees\" the world?\"",
            options: [
                Dialog.Option(text: "Yeah, it looks messy haha. How is it for you?", leadsTo: .A5),
                Dialog.Option(text: "Not yet, how is it?", leadsTo: .A5),
            ]
        ),
        Dialog(
            moment: .A5,
            text: "\"To me it is as if cartoon thought bubbles started to pop up, calling my attention to it until I can't do nothing but stop everything I'm doing to see what it is.\nHave you ever experienced something like that?\"",
            options: [
                Dialog.Option(text: "Yes! Completly relatable.", leadsTo: .A6),
                Dialog.Option(text: "Nothing like that. It seems pretty bad.", leadsTo: .A7),
            ]
        ),
        Dialog(
            moment: .A6,
            text: "\"Then perhaps you know how hard it is the school life of an ADHDer: chaos.\"",
            options: [
                Dialog.Option(text: "[...]", leadsTo: .B1),
            ]
        ),
        Dialog(
            moment: .A7,
            text: "\"It is complicated. Now think about the school context where I NEED to sit still and study for long long hours.\"",
            options: [
                Dialog.Option(text: "Yeah, that's probably a difficult thing to do.", leadsTo: .B1),
            ]
        ),
        Dialog(
            moment: .B1,
            text: "\"I have an American History exam coming up this week...\nWhat if you help me study? I have written some flashcards here... somewhere...\"",
            options: [
                Dialog.Option(text: "Of course! I would love to help.", leadsTo: .B2),
                Dialog.Option(text: "Nah, I can't right now, sorry.", leadsTo: .Home),
            ]
        ),
        Dialog(
            moment: .B2,
            text: "\"Thank you! I will set a timer for 45 seconds, let's see how many questions can we solve before it!\"",
            options: [
                Dialog.Option(text: "Let's go!", leadsTo: .Quizz),
            ]
        ),
        Dialog(
            moment: .Home,
            text: "\"\"",
            options: [
                Dialog.Option(text: "", leadsTo: .Home),
                Dialog.Option(text: "", leadsTo: .Home),
            ]
        ),
    ]
    
    let posExamDialogs: [Dialog] = [
        Dialog(
            moment: .C1,
            text: "\"Oh nice! That was intense. Thank you for helping me out! It is pretty hard to focus on solving the questions, isn't?\"",
            options: [
                Dialog.Option(text: "Wow, yes! I struggled trying to read the questions and choosing the right answer...", leadsTo: .C2),
                Dialog.Option(text: "It was pretty difficult indeed. Do you always go throught this?", leadsTo: .C2),
            ]
        ),
        Dialog(
            moment: .C2,
            text: "\"This is my and others everyday reality. I always have to do an extra effort just to be able to read the questions to the end without distracting myself.\"",
            options: [
                Dialog.Option(text: "[...]", leadsTo: .D1),
            ]
        ),
        Dialog(
            moment: .D1,
            text: "\"Now imagine that constantly throught the day, everyday.\n You are making a sandwich, the phone rings and you go answer it. Then three hours later you come back to a halfdone sandwich on the counter and the peanut butter jar opened next to it.\"",
            options: [
                Dialog.Option(text: "Oh no, my sandwich!", leadsTo: .D2),
            ]
        ),
        Dialog(
            moment: .D2,
            text: "\"This is how people with ADHD live their lives. Some situations are harder than others, but they all share the frustrations and complications that come alongside this condition.\"",
            options: [
                Dialog.Option(text: "[...]", leadsTo: .D3),
            ]
        ),
        Dialog(
            moment: .D3,
            text: "\"In the United States alone, ADHD affects, approximately, 6.1 million kids and 4.4% of adults between 18 and 44 years.\nThose numbers are too high to ignore and do nothing about it!\"",
            options: [
                Dialog.Option(text: "Truly high numbers...", leadsTo: .E1),
            ]
        ),
        Dialog(
            moment: .E1,
            text: "\"But not everything is lost! There are paliative measures that help handling this condition. It is very common to take medication that help in these situations ir order to avoid something dangerous as leaving the stove on overnight.\"",
            options: [
                Dialog.Option(text: "Tell me more about it.", leadsTo: .E2),
            ]
        ),
        Dialog(
            moment: .E2,
            text: "\"Sure! Another measure that helps a lot in the macroscale is to facilitate the access to information about ADHD. Only 1 in 4 adults that have it are diagnosticated and under treatment. I myself found out about it only when I was 21 years old, after suffering throughtout my school life.\"",
            options: [
                Dialog.Option(text: "21 years handling all that chaos that was studying??", leadsTo: .E3),
            ]
        ),
        Dialog(
            moment: .E3,
            text: "\"Yes! I always felt like a failure for having bad grades. I saw many times the disappointment in the eyes of my parents and teachers.\"",
            options: [
                Dialog.Option(text: "Oh, that seems very frustrating...", leadsTo: .E4),
            ]
        ),
        Dialog(
            moment: .E4,
            text: "\"It was hard... Luckly I figured why I kept getting bad grades and didn't develop some psychological problem.\nDid you know that up to 70% of ADHDers has a comorbidity like anxiety and depression?\"",
            options: [
                Dialog.Option(text: "Wow! 70% is a huge percentage...", leadsTo: .E5),
            ]
        ),
        Dialog(
            moment: .E5,
            text: "\"I was lucky for \"only\" having ADHD. There are a lot of hard situations out there and I think we should talk a lot more about it.\"",
            options: [
                Dialog.Option(text: "Yes, we should!", leadsTo: .F1),
            ]
        ),
        Dialog(
            moment: .F1,
            text: "\"I hope I was able to recreate what is like having ADHD putting you in my shoes and showcase what many people go through daily. Thank you so so much for listening to me! Until next time!\"",
            options: [
                Dialog.Option(text: "Bye bye!", leadsTo: .Home),
            ]
        ),
    ]
    
    func setPhase(_ gamePhase: GamePhase) {
        switch gamePhase {
        case .PreExam:
            self.dialogs = preExamDialogs
        case .PosExam:
            self.dialogs = posExamDialogs
        default:
            self.dialogs = []
        }
    }
}

