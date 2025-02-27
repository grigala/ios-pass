//
// CustomFieldEditionCoordinator.swift
// Proton Pass - Created on 10/05/2023.
// Copyright (c) 2023 Proton Technologies AG
//
// This file is part of Proton Pass.
//
// Proton Pass is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Pass is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Pass. If not, see https://www.gnu.org/licenses/.

import Client
import Core
import SwiftUI

struct CustomFieldUiModel: Identifiable {
    var id = UUID().uuidString
    var customField: CustomField
}

protocol CustomFieldEditionDelegate: AnyObject {
    func customFieldEdited(_ uiModel: CustomFieldUiModel, newTitle: String)
}

final class CustomFieldEditionCoordinator: DeinitPrintable, CustomCoordinator {
    deinit { print(deinitMessage) }

    weak var rootViewController: UIViewController!
    let delegate: CustomFieldEditionDelegate
    let uiModel: CustomFieldUiModel

    init(rootViewController: UIViewController,
         delegate: CustomFieldEditionDelegate,
         uiModel: CustomFieldUiModel) {
        self.rootViewController = rootViewController
        self.delegate = delegate
        self.uiModel = uiModel
    }

    func start() {
        let alert = UIAlertController(title: "Edit field title",
                                      message: "Enter new title for \"\(uiModel.customField.title)\"",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "New field title"
            let action = UIAction { _ in
                alert.actions.first?.isEnabled = textField.text?.isEmpty == false
            }
            textField.addAction(action, for: .editingChanged)
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [uiModel, delegate] _ in
            delegate.customFieldEdited(uiModel, newTitle: alert.textFields?.first?.text ?? "")
        }
        saveAction.isEnabled = false
        alert.addAction(saveAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        rootViewController.topMostViewController.present(alert, animated: true)
    }
}
