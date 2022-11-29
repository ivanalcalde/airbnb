import L, { marker } from "leaflet";

class Map {
  constructor(element, center, { markerOnClick, mapOnClick }) {
    this.map = L.map(element).setView(center, 13);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution:
        '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 18,
      tileSize: 512,
      zoomOffset: -1,
    }).addTo(this.map);

    this.markerOnClick = markerOnClick;

    this.map.on("click", mapOnClick);
  }

  addMarker(location) {
    const marker = L.marker([location.lat, location.lng], {
      locationId: location.id,
    })
      .addTo(this.map)
      .bindPopup(location.description);

    marker.on("click", (e) => {
      marker.openPopup();
      this.markerOnClick(e);
    });

    return marker;
  }

  removeAllMarkers() {
    this.map.eachLayer((layer) => {
      if (layer instanceof L.Marker) {
        layer.removeFrom(this.map)
      }
    })
  }

  highlightMarker(location) {
    const marker = this.markerForLocation(location);

    marker.openPopup();

    this.map.panTo(marker.getLatLng());
  }

  markerForLocation(location) {
    let markerLayer;
    this.map.eachLayer((layer) => {
      if (layer instanceof L.Marker) {
        const markerPosition = layer.getLatLng();
        if (
          markerPosition.lat === location.lat &&
          markerPosition.lng === location.lng
        ) {
          markerLayer = layer;
        }
      }
    });

    return markerLayer;
  }
}

export default Map;
