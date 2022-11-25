import Map from "./map";

let Hooks = {};

Hooks.Map = {
  mounted() {
    this.map = new Map(this.el, [42.77, -0.35], (event) => {
      // const locationId = event.target.options.locationId;
      // this.pushEvent("marker-clicked", locationId, (reply, ref) => {
      //   this.scrollTo(reply.location.id)
      // })
    });

    // this.pushEvent("get-locations", {}, (reply, ref) => {
    //   reply.locations.forEach(location => {
    //     this.map.addMarker(location)
    //   })
    // })

    // const locations = JSON.parse(this.el.dataset.locations);

    // incidents.forEach(incident => {
    //   this.map.addMarker(incident);
    // })

    this.handleEvent("highlight-marker", (location) => {
      this.map.highlightMarker(location);
    });

    this.handleEvent("add-marker", (location) => {
      this.map.addMarker(location);
      this.map.highlightMarker(location);
      // this.scrollTo(location.id)
    });
  },

  // scrollTo(locationId) {
  //   const locationElement =
  //     document.querySelector(`[phx-value-id="${locationId}"]`);
  //
  //   locationElement.scrollIntoView(false);
  // }
};

export default Hooks;
