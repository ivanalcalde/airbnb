import Map from "./map";

let Hooks = {};

Hooks.AdminPropertyMap = {
  mounted() {
    const center = JSON.parse(this.el.dataset.mapcenter);

    const markerOnClick = (event) => {
      // const locationId = event.target.options.locationId;
      // this.pushEvent("marker-clicked", locationId, (reply, ref) => {
      //   this.scrollTo(reply.location.id)
      // })
    };

    const mapOnClick = (event) => {
      const { lat, lng } = event.latlng;

      this.pushEvent("set_coordinates", { lat, lng });
    };

    this.map = new Map(this.el, center, {
      mapOnClick,
      markerOnClick,
    });

    this.handleEvent("update_location", location => {
      this.map.removeAllMarkers();

      this.map.addMarker(location);
    });

    // this.pushEvent("get-locations", {}, (reply, ref) => {
    //   reply.locations.forEach(location => {
    //     this.map.addMarker(location)
    //   })
    // })

    // this.handleEvent("highlight-marker", (location) => {
    //   this.map.highlightMarker(location);
    // });

    // this.handleEvent("add-marker", (location) => {
    //   this.map.addMarker(location);
    //   this.map.highlightMarker(location);
    //   this.scrollTo(location.id)
    // });
  },

  // scrollTo(locationId) {
  //   const locationElement =
  //     document.querySelector(`[phx-value-id="${locationId}"]`);
  //
  //   locationElement.scrollIntoView(false);
  // }
};

export default Hooks;
