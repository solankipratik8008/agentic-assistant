//
//  MapSearchView.swift
//  Agentic Personal Assistant
//
//  Created by Pratik Solanki on 2026-04-17.
//

import SwiftUI
import MapKit

// MARK: - Identifiable Wrapper for MKMapItem
struct IdentifiableMapItem: Identifiable {
    let id: Int
    let mapItem: MKMapItem
    
    init(index: Int, mapItem: MKMapItem) {
        self.id = index
        self.mapItem = mapItem
    }
}

struct MapSearchView: View {
    let query: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedItem: MKMapItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: searchResults.indices.map { IdentifiableMapItem(index: $0, mapItem: searchResults[$0]) }) { item in
                    MapMarker(coordinate: item.mapItem.placemark.coordinate, tint: .blue)
                }
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    if !searchResults.isEmpty {
                        resultsList
                            .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle("Map Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await searchPlaces()
            }
        }
    }
    
    private var resultsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(searchResults, id: \.self) { item in
                    PlaceResultCard(mapItem: item) {
                        openInMaps(item)
                    }
                }
            }
            .padding()
        }
        .frame(maxHeight: 300)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
    
    private func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        // Try to use current location
        let locationService = LocationService.shared
        if let location = locationService.currentLocation {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            region = request.region
        }
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            searchResults = response.mapItems
            
            // Update region to show all results
            if let firstItem = response.mapItems.first {
                region = MKCoordinateRegion(
                    center: firstItem.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        } catch {
            print("Search error: \(error)")
        }
    }
    
    private func openInMaps(_ item: MKMapItem) {
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Place Result Card
struct PlaceResultCard: View {
    let mapItem: MKMapItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(mapItem.name ?? "Unknown")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let address = formatAddress(mapItem.placemark) {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let phone = mapItem.phoneNumber {
                    Text(phone)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 2)
        }
    }
    
    private func formatAddress(_ placemark: MKPlacemark) -> String? {
        var components: [String] = []
        
        if let street = placemark.thoroughfare {
            components.append(street)
        }
        if let city = placemark.locality {
            components.append(city)
        }
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}

// MARK: - Preview
#Preview {
    MapSearchView(query: "coffee near me")
}
