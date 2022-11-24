defmodule AirbnbWeb.PropertyPhotosLive do
  use AirbnbWeb, :live_view

  alias Airbnb.Properties

  def mount(%{"id" => property_id}, _session, socket) do
    socket = assign(socket,
      property_id: property_id,
      property: Properties.get_property!(property_id),
      property_photos: Properties.get_property_photos(property_id)
    )

    socket = allow_upload(socket, :photo,
      accept: ~w(.png .jpeg .jpg),
      max_entries: 3,
      max_file_size: 5_000_000,
      external: &generate_metadata/2
    )

    {:ok, socket, temporary_assigns: [property_photos: []]}
  end

  def handle_event("change_photo", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(
    "save_photo",
    %{"photo" => %{"id" => id, "title" => title}},
     socket
  ) do
    {:ok, property_photo} = Properties.update_property_photo(id, %{title: title})

    socket = 
      update(
        socket,
        :property_photos,
        fn property_photos -> [property_photo | property_photos] end
      )

    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    {completed, []} = uploaded_entries(socket, :photo)

    urls = for entry <- completed do
      Path.join(s3_url(), filename(entry))
    end

    Properties.create_property_photos(
      socket.assigns.property_id,
      urls
    )

    consume_uploaded_entries(socket, :photo, fn meta, entry ->
      {:ok, {meta, entry}}
    end)

    property_photos = Properties.get_property_photos(socket.assigns.property_id)

    {:noreply, assign(socket, :property_photos, property_photos)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}  
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <h1 class="text-4xl"><%= @property.title %></h1>
      <h2 class="text-2xl">Property Photos</h2>
      <.form class="space-y-4" for={:property_photos} phx-change="validate" phx-submit="save">

        <div class="p-4 text-xs text-slate-500">
          Add up to <%= @uploads.photo.max_entries %> photos
          (max <%= trunc(@uploads.photo.max_file_size / 1_000_000) %> MB each)
        </div>

        <div class="p-4 rounded-lg border-2 border-dashed border-slate-200" phx-drop-target={@uploads.photo.ref}>
          <.live_file_input upload={@uploads.photo} />
          or drag and drop here
        </div>

        <.error :for={{_ref, error} <- @uploads.photo.errors} error={error} />

        <div :for={entry <- @uploads.photo.entries} class="p-2 flex items-center justify-start space-x-6">
          <.live_img_preview entry={entry} width={150} />

          <.progress value={entry.progress} />

          <a class="text-3xl font-bold text-gray-700 hover:text-red-700"
             href="#" phx-click="cancel" phx-value-ref={entry.ref}>
            &times;
          </a>

          <.error :for={error <- upload_errors(@uploads.photo, entry)} error={error} />
        </div>

        <div>
          <%= submit "Upload", phx_disable_with: "Uploading...", class: "button" %>
        </div>
      </.form>
      <h2 class="text-2xl">Gallery</h2>
      <div :if={length(@property_photos) == 0}>Property has no photos yet</div>
      <div id="photos" phx-update="prepend" class="p-4 bg-gray-100">
        <div
          class="flex space-x-4 items-center p-4 border-dashed border-b-2 border-white"
          id={"photo-#{photo.id}"}
          :for={photo <- @property_photos}
        >
          <img src={photo.url} class="w-64" />
          <.form
            :let={f}
            for={:photo}
            phx-change="change_photo"
            phx-submit="save_photo"
          >
            <%= hidden_input f, :id, value: photo.id %>
            <%= label f, :title, "Title" %>
            <%= text_input f, :title, value: photo.title, placeholder: "Photo Title" %>
            <%= submit "Save", phx_disable_with: "Saving...", class: "button" %>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  def progress(assigns) do
    ~H"""
    <div class="w-full">
      <div class="text-left mb-2 text-xs font-semibold inline-block text-pink-600"><%= @value %>%</div>
      <div class="flex h-2 overflow-hidden text-base bg-pink-200 rounded-lg mb-4">
        <span
            class="shadow-md bg-pink-500 transition ease-linear duration-1000"
            style={"width: #{@value}%"}>
        </span>
      </div>
    </div>
    """
  end

  def error(assigns) do
    ~H"""
    <div class="p-2 text-red-700"><%= error_to_string(@error) %></div>
    """
  end

  @s3_bucket "airbnb-clone-uploads"

  defp s3_url, do: "//#{@s3_bucket}.s3.amazonaws.com"

  defp filename(entry) do
    [ext | _t] = MIME.extensions(entry.client_type)
    "#{entry.uuid}.#{ext}"
  end

  defp generate_metadata(entry, socket) do
    config = %{
      region: "eu-central-1",
      access_key_id: Application.fetch_env!(:airbnb, :s3_access_key_id),
      secret_access_key: Application.fetch_env!(:airbnb, :s3_secret_access_key)
    }

    {:ok, fields} =
      SimpleS3Upload.sign_form_upload(config, @s3_bucket,
        key: filename(entry),
        content_type: entry.client_type,
        max_file_size: socket.assigns.uploads.photo.max_file_size,
        expires_in: :timer.hours(1)
      )

    metadata = %{
      uploader: "S3",
      key: filename(entry),
      url: s3_url(),
      fields: fields
    }
    
    {:ok, metadata, socket}
  end

  def error_to_string(:too_large),
    do: "File too large (max 10 MB)."

  def error_to_string(:too_many_files),
    do: "You've selected too many files."

  def error_to_string(:not_accepted),
    do: "You've selected an unacceptable file type."

  def error_to_string(error),
    do: humanize(error)
end
