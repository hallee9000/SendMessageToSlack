//
//  Created by hallee on 2025/11/5.


import SwiftUI

struct IconLabel: View {
    let title: String
    let icon: String
    var color: Color = .secondary

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
    }
}

#Preview("IconLabel") {
    VStack (alignment: .leading, spacing: 4) {
        IconLabel(title: "Bot Token", icon: "key.fill")
        TextField(
            "#general or C1234567890",
            text: .constant("这是一个静态的文本")
        )
            .controlSize(.large)
            .textFieldStyle(.roundedBorder)
    }
        .padding(20)
}
