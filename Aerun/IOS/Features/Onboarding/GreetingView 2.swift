//
//  GreetingView.swift
//  Aerun
//
//  Layar onboarding pertama — menyapa user dan meminta nama mereka.
//  Nama yang dimasukkan disimpan ke UserDefaults key "aerun_user_name"
//  supaya bisa ditampilkan di HomeView: "Hello, Nama!"
//
//  Light & Dark Mode: otomatis via Color(.systemBackground) dan .primary
//

import SwiftUI

struct GreetingView: View {

    // Closure yang dipanggil saat user selesai di halaman ini dan mau lanjut
    // Tipe () -> Void = fungsi tanpa parameter dan tanpa return value
    let onNext: () -> Void

    // @AppStorage langsung terhubung ke UserDefaults key "aerun_user_name"
    // Saat nilai ini berubah, UserDefaults otomatis diupdate
    @AppStorage("aerun_user_name") private var userName: String = ""

    // @State = state lokal untuk text field — belum disimpan sampai user tap "Next"
    @State private var inputName: String = ""

    // @FocusState = mengontrol apakah text field sedang fokus (keyboard muncul)
    @FocusState private var isFieldFocused: Bool

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background adaptive — hitam di dark mode, putih di light mode
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // --- Sapaan ---
                Text("Hello!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)  // Adaptive: hitam/putih sesuai mode

                // Logo app dengan warna mint brand
                Text("aeRUN♥")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .foregroundStyle(.mint)
                    .padding(.top, 24)

                // Tagline
                Text("is here to help you \n start your running journey \n with less worry")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(.top, 12)

                // --- Input Nama ---
                // Meminta nama supaya HomeView bisa menyapa "Hello, Nama!"
                VStack(alignment: .leading, spacing: 8) {
                    Text("What should we call you?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // TextField dengan styling kustom
                    TextField("Your name", text: $inputName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .focused($isFieldFocused)   // Kaitkan dengan FocusState
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        // Background field adaptive
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.top, 32)

                Spacer()

                // --- Tombol Next ---
                Button {
                    // Trim whitespace di awal/akhir nama
                    let trimmed = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
                    // Simpan ke UserDefaults — kalau kosong, pakai "Runner" sebagai default
                    userName = trimmed.isEmpty ? "Runner" : trimmed
                    withAnimation {
                        onNext()  // Panggil closure dari parent → pindah ke step berikutnya
                    }
                } label: {
                    Text("Next")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 300, height: 30)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            // Kalau user sudah pernah isi nama sebelumnya, pre-fill text field
            if !userName.isEmpty && userName != "Runner" {
                inputName = userName
            }
        }
    }
}

#Preview {
    GreetingView {
        print("Next tapped")
    }
}
