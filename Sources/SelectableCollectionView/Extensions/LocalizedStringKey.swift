// https://stackoverflow.com/questions/64429554/how-to-get-string-value-from-localizedstringkey

import SwiftUI

extension LocalizedStringKey {

    private typealias FArgs = (CVarArg, Formatter?)

    var localized: String? {
        let mirror = Mirror(reflecting: self)
        let key: String? = mirror.descendant("key") as? String

        guard let key else {
            return nil
        }

        var fargs: [FArgs] = []

        if let arguments = mirror.descendant("arguments") as? Array<Any> {
            for argument in arguments {
                let argumentMirror = Mirror(reflecting: argument)

                if let storage = argumentMirror.descendant("storage") {
                    let storageMirror = Mirror(reflecting: storage)

                    if let formatStyleValue = storageMirror.descendant("formatStyleValue") {
                        let formatStyleValueMirror = Mirror(reflecting: formatStyleValue)

                        guard var input = formatStyleValueMirror.descendant("input") as? CVarArg else {
                            continue
                        }

                        let formatter: Formatter? = nil

                        if let _ = formatStyleValueMirror.descendant("format") {
                            // Cast input to String
                            input = String(describing: input) as CVarArg
                        }

                        fargs.append((input, formatter))
                    } else if let storageValue = storageMirror.descendant("value") as? FArgs {
                        fargs.append(storageValue)
                    }
                }
            }
        }

        let string = NSLocalizedString(key, comment: "")

        if mirror.descendant("hasFormatting") as? Bool ?? false {
            return String.localizedStringWithFormat(
                string,
                fargs.map { arg, formatter in
                    formatter?.string(for: arg) ?? arg
                }
            )
        } else {
            return string
        }
    }
}
