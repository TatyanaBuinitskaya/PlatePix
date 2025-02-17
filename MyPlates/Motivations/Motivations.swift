//
//  Motivations.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 12.02.2025.
//

import Foundation

//struct Motivations {
//    static let motivations = [
//        Motivation (
//            id: 0, text: String.LocalizationValue("Motivation0")
//        ),
//        Motivation (
//            id: 1, text: String.LocalizationValue("Motivation1")
//        ),
//        Motivation (
//            id: 2, text: String.LocalizationValue("Motivation2")
//        ),
//        Motivation (
//            id: 3, text: String.LocalizationValue("Motivation3")
//        ),
//        Motivation (
//            id: 4, text: String.LocalizationValue("Motivation4")
//        ),
//        Motivation (
//            id: 5, text: String.LocalizationValue("Motivation5")
//        ),
//        Motivation (
//            id: 6, text: String.LocalizationValue("Motivation6")
//        ),
//        Motivation (
//            id: 7, text: String.LocalizationValue("Motivation7")
//        ),
//        Motivation (
//            id: 8, text: String.LocalizationValue("Motivation8")
//        ),
//        Motivation (
//            id: 9, text: String.LocalizationValue("Motivation9")
//        ),

//        Motivation (
//            id: 4, text: LocalizedStringResource("Motivation4", table: "Motivations")
//        ),
//        Motivation (
//            id: 5, text: LocalizedStringResource("Motivation5", table: "Motivations")
//        ),
//        Motivation (
//            id: 6, text: LocalizedStringResource("Motivation6", table: "Motivations")
//        ),
//        Motivation (
//            id: 7, text: LocalizedStringResource("Motivation7", table: "Motivations")
//        ),
//        Motivation (
//            id: 8, text: LocalizedStringResource("Motivation8", table: "Motivations")
//        ),
//        Motivation (
//            id: 9, text: LocalizedStringResource("Motivation9", table: "Motivations")
//        ),
//        Motivation (
//            id: 10, text: LocalizedStringResource("Motivation10", table: "Motivations")
//        ),
//        Motivation (
//            id: 11, text: LocalizedStringResource("Motivation11", table: "Motivations")
//        ),
//        Motivation (
//            id: 12, text: LocalizedStringResource("Motivation12", table: "Motivations")
//        ),
//        Motivation (
//            id: 13, text: LocalizedStringResource("Motivation13", table: "Motivations")
//        ),
//        Motivation (
//            id: 14, text: LocalizedStringResource("Motivation14", table: "Motivations")
//        ),
//        Motivation (
//            id: 15, text: LocalizedStringResource("Motivation15", table: "Motivations")
//        ),
//        Motivation (
//            id: 16, text: LocalizedStringResource("Motivation16", table: "Motivations")
//        ),
//        Motivation (
//            id: 17, text: LocalizedStringResource("Motivation17", table: "Motivations")
//        ),
//        Motivation (
//            id: 18, text: LocalizedStringResource("Motivation18", table: "Motivations")
//        ),
//        Motivation (
//            id: 19, text: LocalizedStringResource("Motivation19", table: "Motivations")
//        ),
//        Motivation (
//            id: 20, text: LocalizedStringResource("Motivation20", table: "Motivations")
//        ),
//        Motivation (
//            id: 21, text: LocalizedStringResource("Motivation21", table: "Motivations")
//        ),
//        Motivation (
//            id: 22, text: LocalizedStringResource("Motivation22", table: "Motivations")
//        ),
//        Motivation (
//            id: 23, text: LocalizedStringResource("Motivation23", table: "Motivations")
//        ),
//        Motivation (
//            id: 24, text: LocalizedStringResource("Motivation24", table: "Motivations")
//        ),
//        Motivation (
//            id: 25, text: LocalizedStringResource("Motivation25", table: "Motivations")
//        ),
//        Motivation (
//            id: 26, text: LocalizedStringResource("Motivation26", table: "Motivations")
//        ),
//        Motivation (
//            id: 27, text: LocalizedStringResource("Motivation27", table: "Motivations")
//        ),
//        Motivation (
//            id: 28, text: LocalizedStringResource("Motivation28", table: "Motivations")
//        ),
//        Motivation (
//            id: 29, text: LocalizedStringResource("Motivation29", table: "Motivations")
//            ),
//        Motivation (
//            id: 30, text: LocalizedStringResource("Motivation30", table: "Motivations")
//        ),
//        Motivation (
//            id: 31, text: LocalizedStringResource("Motivation31", table: "Motivations")
//        ),
//        Motivation (
//            id: 32, text: LocalizedStringResource("Motivation32", table: "Motivations")
//        ),
//        Motivation (
//            id: 33, text: LocalizedStringResource("Motivation33", table: "Motivations")
//        ),
//        Motivation (
//            id: 34, text: LocalizedStringResource("Motivation34", table: "Motivations")
//        ),
//        Motivation (
//            id: 35, text: LocalizedStringResource("Motivation35", table: "Motivations")
//        ),
//        Motivation (
//            id: 36, text: LocalizedStringResource("Motivation36", table: "Motivations")
//        ),
//        Motivation (
//            id: 37, text: LocalizedStringResource("Motivation37", table: "Motivations")
//        ),
//        Motivation (
//            id: 38, text: LocalizedStringResource("Motivation38", table: "Motivations")
//        ),
//        Motivation (
//            id: 39, text: LocalizedStringResource("Motivation39", table: "Motivations")
//        ),
//        Motivation (
//            id: 40, text: LocalizedStringResource("Motivation40", table: "Motivations")
//        ),
//        Motivation (
//            id: 41, text: LocalizedStringResource("Motivation41", table: "Motivations")
//        ),
//        Motivation (
//            id: 42, text: LocalizedStringResource("Motivation42", table: "Motivations")
//        ),
//        Motivation (
//            id: 43, text: LocalizedStringResource("Motivation43", table: "Motivations")
//        ),
//        Motivation (
//            id: 44, text: LocalizedStringResource("Motivation44", table: "Motivations")
//        ),
//        Motivation (
//            id: 45, text: LocalizedStringResource("Motivation45", table: "Motivations")
//        ),
//        Motivation (
//            id: 46, text: LocalizedStringResource("Motivation46", table: "Motivations")
//        ),
//        Motivation (
//            id: 47, text: LocalizedStringResource("Motivation47", table: "Motivations")
//        ),
//        Motivation (
//            id: 48, text: LocalizedStringResource("Motivation48", table: "Motivations")
//        ),
//        Motivation (
//            id: 49, text: LocalizedStringResource("Motivation49", table: "Motivations")
//        ),
//        Motivation (
//            id: 50, text: LocalizedStringResource("Motivation50", table: "Motivations")
//        ),
//        Motivation (
//            id: 51, text: LocalizedStringResource("Motivation51", table: "Motivations")
//        ),
//        Motivation (
//            id: 52, text: LocalizedStringResource("Motivation52", table: "Motivations")
//        ),
//        Motivation (
//            id: 53, text: LocalizedStringResource("Motivation53", table: "Motivations")
//        ),
//        Motivation (
//            id: 54, text: LocalizedStringResource("Motivation54", table: "Motivations")
//        ),
//        Motivation (
//            id: 55, text: LocalizedStringResource("Motivation55", table: "Motivations")
//        ),
//        Motivation (
//            id: 56, text: LocalizedStringResource("Motivation56", table: "Motivations")
//        ),
//        Motivation (
//            id: 57, text: LocalizedStringResource("Motivation57", table: "Motivations")
//        ),
//        Motivation (
//            id: 58, text: LocalizedStringResource("Motivation58", table: "Motivations")
//        ),
//        Motivation (
//            id: 59, text: LocalizedStringResource("Motivation59", table: "Motivations")
//            ),
//        Motivation (
//            id: 60, text: LocalizedStringResource("Motivation60", table: "Motivations")
//        ),
//        Motivation (
//            id: 61, text: LocalizedStringResource("Motivation61", table: "Motivations")
//        ),
//        Motivation (
//            id: 62, text: LocalizedStringResource("Motivation62", table: "Motivations")
//        ),
//        Motivation (
//            id: 63, text: LocalizedStringResource("Motivation63", table: "Motivations")
//        ),
//        Motivation (
//            id: 64, text: LocalizedStringResource("Motivation64", table: "Motivations")
//        ),
//        Motivation (
//            id: 65, text: LocalizedStringResource("Motivation65", table: "Motivations")
//        ),
//        Motivation (
//            id: 66, text: LocalizedStringResource("Motivation66", table: "Motivations")
//        ),
//        Motivation (
//            id: 67, text: LocalizedStringResource("Motivation67", table: "Motivations")
//        ),
//        Motivation (
//            id: 68, text: LocalizedStringResource("Motivation68", table: "Motivations")
//        ),
//        Motivation (
//            id: 69, text: LocalizedStringResource("Motivation69", table: "Motivations")
//        ),
//        Motivation (
//            id: 70, text: LocalizedStringResource("Motivation70", table: "Motivations")
//        ),
//        Motivation (
//            id: 71, text: LocalizedStringResource("Motivation71", table: "Motivations")
//        ),
//        Motivation (
//            id: 72, text: LocalizedStringResource("Motivation72", table: "Motivations")
//        ),
//        Motivation (
//            id: 73, text: LocalizedStringResource("Motivation73", table: "Motivations")
//        ),
//        Motivation (
//            id: 74, text: LocalizedStringResource("Motivation74", table: "Motivations")
//        ),
//        Motivation (
//            id: 75, text: LocalizedStringResource("Motivation75", table: "Motivations")
//        ),
//        Motivation (
//            id: 76, text: LocalizedStringResource("Motivation76", table: "Motivations")
//        ),
//        Motivation (
//            id: 77, text: LocalizedStringResource("Motivation77", table: "Motivations")
//        ),
//        Motivation (
//            id: 78, text: LocalizedStringResource("Motivation78", table: "Motivations")
//        ),
//        Motivation (
//            id: 79, text: LocalizedStringResource("Motivation79", table: "Motivations")
//        ),
//        Motivation (
//            id: 80, text: LocalizedStringResource("Motivation80", table: "Motivations")
//        ),
//        Motivation (
//            id: 81, text: LocalizedStringResource("Motivation81", table: "Motivations")
//        ),
//        Motivation (
//            id: 82, text: LocalizedStringResource("Motivation82", table: "Motivations")
//        ),
//        Motivation (
//            id: 83, text: LocalizedStringResource("Motivation83", table: "Motivations")
//        ),
//        Motivation (
//            id: 84, text: LocalizedStringResource("Motivation84", table: "Motivations")
//        ),
//        Motivation (
//            id: 85, text: LocalizedStringResource("Motivation85", table: "Motivations")
//        ),
//        Motivation (
//            id: 86, text: LocalizedStringResource("Motivation86", table: "Motivations")
//        ),
//        Motivation (
//            id: 87, text: LocalizedStringResource("Motivation87", table: "Motivations")
//        ),
//        Motivation (
//            id: 88, text: LocalizedStringResource("Motivation88", table: "Motivations")
//        ),
//        Motivation (
//            id: 89, text: LocalizedStringResource("Motivation89", table: "Motivations")
//            ),
//        Motivation (
//            id: 90, text: LocalizedStringResource("Motivation90", table: "Motivations")
//        )
//    ]
//}

struct Motivations {
    static let motivations = [
        Motivation(id: 0, textKey: "Motivation0"),
        Motivation(id: 1, textKey: "Motivation1"),
        Motivation(id: 2, textKey: "Motivation2"),
        Motivation(id: 3, textKey: "Motivation3"),
        Motivation(id: 4, textKey: "Motivation4"),
        Motivation(id: 5, textKey: "Motivation5"),
        Motivation(id: 6, textKey: "Motivation6"),
        Motivation(id: 7, textKey: "Motivation7"),
        Motivation(id: 8, textKey: "Motivation8"),
        Motivation(id: 9, textKey: "Motivation9"),
        Motivation(id: 10, textKey: "Motivation10"),
        Motivation(id: 11, textKey: "Motivation11"),
        Motivation(id: 12, textKey: "Motivation12"),
        Motivation(id: 13, textKey: "Motivation13"),
        Motivation(id: 14, textKey: "Motivation14"),
        Motivation(id: 15, textKey: "Motivation15"),
        Motivation(id: 16, textKey: "Motivation16"),
        Motivation(id: 17, textKey: "Motivation17"),
        Motivation(id: 18, textKey: "Motivation18"),
        Motivation(id: 19, textKey: "Motivation19"),
        Motivation(id: 20, textKey: "Motivation20"),
        Motivation(id: 21, textKey: "Motivation21"),
        Motivation(id: 22, textKey: "Motivation22"),
        Motivation(id: 23, textKey: "Motivation23"),
        Motivation(id: 24, textKey: "Motivation24"),
        Motivation(id: 25, textKey: "Motivation25"),
        Motivation(id: 26, textKey: "Motivation26"),
        Motivation(id: 27, textKey: "Motivation27"),
        Motivation(id: 28, textKey: "Motivation28"),
        Motivation(id: 29, textKey: "Motivation29"),
        Motivation(id: 30, textKey: "Motivation30"),
        Motivation(id: 31, textKey: "Motivation31"),
        Motivation(id: 32, textKey: "Motivation32"),
        Motivation(id: 33, textKey: "Motivation33"),
        Motivation(id: 34, textKey: "Motivation34"),
        Motivation(id: 35, textKey: "Motivation35"),
        Motivation(id: 36, textKey: "Motivation36"),
        Motivation(id: 37, textKey: "Motivation37"),
        Motivation(id: 38, textKey: "Motivation38"),
        Motivation(id: 39, textKey: "Motivation39"),
        Motivation(id: 40, textKey: "Motivation40"),
        Motivation(id: 41, textKey: "Motivation41"),
        Motivation(id: 42, textKey: "Motivation42"),
        Motivation(id: 43, textKey: "Motivation43"),
        Motivation(id: 44, textKey: "Motivation44"),
        Motivation(id: 45, textKey: "Motivation45"),
        Motivation(id: 46, textKey: "Motivation46"),
        Motivation(id: 47, textKey: "Motivation47"),
        Motivation(id: 48, textKey: "Motivation48"),
        Motivation(id: 49, textKey: "Motivation49"),
        Motivation(id: 50, textKey: "Motivation50"),
        Motivation(id: 51, textKey: "Motivation51"),
        Motivation(id: 52, textKey: "Motivation52"),
        Motivation(id: 53, textKey: "Motivation53"),
        Motivation(id: 54, textKey: "Motivation54"),
        Motivation(id: 55, textKey: "Motivation55"),
        Motivation(id: 56, textKey: "Motivation56"),
        Motivation(id: 57, textKey: "Motivation57"),
        Motivation(id: 58, textKey: "Motivation58"),
        Motivation(id: 59, textKey: "Motivation59"),
        Motivation(id: 60, textKey: "Motivation60"),
        Motivation(id: 61, textKey: "Motivation61"),
        Motivation(id: 62, textKey: "Motivation62"),
        Motivation(id: 63, textKey: "Motivation63"),
        Motivation(id: 64, textKey: "Motivation64"),
        Motivation(id: 65, textKey: "Motivation65"),
        Motivation(id: 66, textKey: "Motivation66"),
        Motivation(id: 67, textKey: "Motivation67"),
        Motivation(id: 68, textKey: "Motivation68"),
        Motivation(id: 69, textKey: "Motivation69"),
        Motivation(id: 70, textKey: "Motivation70"),
        Motivation(id: 71, textKey: "Motivation71"),
        Motivation(id: 72, textKey: "Motivation72"),
        Motivation(id: 73, textKey: "Motivation73"),
        Motivation(id: 74, textKey: "Motivation74"),
        Motivation(id: 75, textKey: "Motivation75"),
        Motivation(id: 76, textKey: "Motivation76"),
        Motivation(id: 77, textKey: "Motivation77"),
        Motivation(id: 78, textKey: "Motivation78"),
        Motivation(id: 79, textKey: "Motivation79"),
        Motivation(id: 80, textKey: "Motivation80"),
        Motivation(id: 81, textKey: "Motivation81"),
        Motivation(id: 82, textKey: "Motivation82"),
        Motivation(id: 83, textKey: "Motivation83"),
        Motivation(id: 84, textKey: "Motivation84"),
        Motivation(id: 85, textKey: "Motivation85"),
        Motivation(id: 86, textKey: "Motivation86"),
        Motivation(id: 87, textKey: "Motivation87"),
        Motivation(id: 88, textKey: "Motivation88"),
        Motivation(id: 89, textKey: "Motivation89"),
        Motivation(id: 90, textKey: "Motivation90")
    ]
}
