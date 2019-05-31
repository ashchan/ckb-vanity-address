import VanityAddress

let generator = VanityAddressGenerator()

do {
    try generator.run()
} catch {
    print("Error: \(error.localizedDescription)")
}
