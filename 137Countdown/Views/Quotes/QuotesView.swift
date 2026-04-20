//
//  QuotesView.swift
//  137Countdown
//

import SwiftUI

struct QuotesView: View {
    @ObservedObject var viewModel: CountdownViewModel

    @State private var showAddQuote = false
    @State private var editingQuote: Quote?
    @State private var searchText = ""
    @State private var isReordering = false

    private var filteredQuotes: [Quote] {
        viewModel.quotesMatching(search: searchText)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Inspiration")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(
                            LinearGradient(colors: [.countdownAccent, Color(red: 1, green: 0.32, blue: 0.05)], startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: Color.countdownAccent.opacity(0.18), radius: 4, y: 2)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "quote.opening")
                            .font(.largeTitle)
                            .foregroundColor(.countdownAccent)

                        Text(viewModel.quoteOfTheDay.text)
                            .font(.title3)
                            .italic()
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)

                        Text("— \(viewModel.quoteOfTheDay.author)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .countdownRaisedCard(cornerRadius: 20, panel: true)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section {
                    Text("Favorite quotes")
                        .font(.headline)
                        .foregroundColor(.black)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                if viewModel.favoriteQuotes.isEmpty {
                    Section {
                        Text("No favorite quotes yet.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .listRowBackground(Color.clear)
                    }
                } else {
                    Section {
                        ForEach(viewModel.favoriteQuotes) { quote in
                            QuoteCard(quote: quote)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteQuote(quote)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        viewModel.toggleQuoteFavorite(quote)
                                    } label: {
                                        Label("Unfavorite", systemImage: "star.slash")
                                    }
                                    .tint(.countdownAccent)
                                }
                        }
                    }
                }

                Section {
                    Text("My quotes")
                        .font(.headline)
                        .foregroundColor(.black)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                if searchText.isEmpty {
                    Section {
                        ForEach(viewModel.quotes) { quote in
                            QuoteCard(quote: quote)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingQuote = quote
                                }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteQuote(quote)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    viewModel.toggleQuoteFavorite(quote)
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                .tint(.countdownAccent)
                            }
                        }
                        .onMove { source, destination in
                            viewModel.moveQuotes(from: source, to: destination)
                        }
                    }
                } else {
                    Section {
                        if filteredQuotes.isEmpty {
                            Text("No quotes match your search.")
                                .foregroundColor(.gray)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(filteredQuotes) { quote in
                                QuoteCard(quote: quote)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        editingQuote = quote
                                    }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .searchable(text: $searchText, prompt: "Search quotes or authors")
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .environment(\.editMode, .constant(isReordering ? .active : .inactive))
            .onChange(of: searchText) { value in
                if !value.isEmpty {
                    isReordering = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(isReordering ? "Done" : "Reorder") {
                        isReordering.toggle()
                    }
                    .disabled(!searchText.isEmpty)
                    .foregroundColor(.countdownAccent)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddQuote = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.countdownAccent)
                    }
                    .accessibilityLabel("Add quote")
                }
            }
            .sheet(isPresented: $showAddQuote) {
                AddQuoteView(viewModel: viewModel)
            }
            .sheet(item: $editingQuote) { quote in
                EditQuoteView(viewModel: viewModel, quote: quote)
            }
        }
    }
}

private struct AddQuoteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CountdownViewModel

    @State private var text = ""
    @State private var author = ""
    @State private var isFavorite = false

    var body: some View {
        NavigationStack {
            ZStack {
                CountdownScreenBackground()

                Form {
                    Section(header: Text("Quote").foregroundColor(.gray)) {
                        TextEditor(text: $text)
                            .frame(minHeight: 120)
                            .foregroundColor(.black)
                            .tint(.countdownAccent)

                        TextField("Author", text: $author)
                            .foregroundColor(.black)
                            .tint(.countdownAccent)
                    }

                    Section {
                        Toggle("Mark as favorite", isOn: $isFavorite)
                            .tint(.countdownAccent)
                    }
                }
                .foregroundColor(.black)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.countdownAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        let quote = Quote(
                            id: UUID(),
                            text: trimmed,
                            author: author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Unknown" : author,
                            isFavorite: isFavorite
                        )
                        viewModel.addQuote(quote)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .countdownAccent)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct EditQuoteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CountdownViewModel

    private let quoteId: UUID
    @State private var text: String
    @State private var author: String
    @State private var isFavorite: Bool

    init(viewModel: CountdownViewModel, quote: Quote) {
        self.viewModel = viewModel
        self.quoteId = quote.id
        _text = State(initialValue: quote.text)
        _author = State(initialValue: quote.author)
        _isFavorite = State(initialValue: quote.isFavorite)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CountdownScreenBackground()

                Form {
                    Section(header: Text("Quote").foregroundColor(.gray)) {
                        TextEditor(text: $text)
                            .frame(minHeight: 120)
                            .foregroundColor(.black)
                            .tint(.countdownAccent)

                        TextField("Author", text: $author)
                            .foregroundColor(.black)
                            .tint(.countdownAccent)
                    }

                    Section {
                        Toggle("Mark as favorite", isOn: $isFavorite)
                            .tint(.countdownAccent)
                    }
                }
                .foregroundColor(.black)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.countdownAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        let authorTrimmed = author.trimmingCharacters(in: .whitespacesAndNewlines)
                        let updated = Quote(
                            id: quoteId,
                            text: trimmed,
                            author: authorTrimmed.isEmpty ? "Unknown" : authorTrimmed,
                            isFavorite: isFavorite
                        )
                        viewModel.updateQuote(updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .countdownAccent)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
