defmodule QuestApiV21Web.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At the first glance, this module may seem daunting, but its goal is
  to provide some core building blocks in your application, such as modals,
  tables, and forms. The components are mostly markup and well documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import QuestApiV21Web.Gettext

  @doc """
  Renders a basic title

  ## Examples

  <.title text="example-title" />
  """
  attr :text, :string, required: true

  def title(assigns) do
    ~H"""
    <h1 class="my-4 text-2xl font-medium text-center text-gray-600">
      <%= @text %>
    </h1>
    """
  end


  attr :current_path, :string, required: true

  def navbar(assigns) do
    ~H"""

        <!-- Bottom Nav -->
          <div class="fixed bottom-0 w-full bg-gradient-to-b from-indigo-100 to-contrast">

          <div class="grid grid-cols-3 justify-items-center">
          <.link patch={"/home"} class={" #{if @current_path == :home, do: "text-gray-900"} py-2 w-14 h-14 text-xs"}>

              <div>
                <!-- Replace with the appropriate icon HTML -->
                <span class={"ml-4 w-6 h-6 hero-home#{if @current_path == :home, do: "-solid"}"}>
                </span>
                <p class={"text-center #{if @current_path == :home, do: "font-bold", else: "font-base"}"}>Home</p>
            </div>
            </.link>

            <.link patch={"/quests"} class={" #{if @current_path == :quests, do: "text-gray-900"} py-2 w-14 h-14 text-xs"}>

            <div>
              <!-- Replace with the appropriate icon HTML -->
              <svg class="ml-4 w-6 h-6" xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="0 0 6484 5810">
                <g><path fill="currentColor" d="M 2846.5,-0.5 C 2884.17,-0.5 2921.83,-0.5 2959.5,-0.5C 3454.78,24.2205 3917.78,158.721 4348.5,403C 4557.06,523.481 4749.39,666.147 4925.5,831C 5028.97,934.361 5123.8,1044.53 5210,1161.5C 5520.98,1585.81 5712.32,2060.15 5784,2584.5C 5798.26,2689.87 5806.09,2795.7 5807.5,2902C 5796.64,3331.25 5700.14,3740.09 5518,4128.5C 5473.13,4222.91 5424.13,4314.91 5371,4404.5C 5370.33,4461.83 5370.33,4519.17 5371,4576.5C 5741.7,4947.37 6112.53,5318.03 6483.5,5688.5C 6483.5,5715.5 6483.5,5742.5 6483.5,5769.5C 6469.83,5782.5 6456.5,5795.83 6443.5,5809.5C 6259.17,5809.5 6074.83,5809.5 5890.5,5809.5C 5486.84,5405.01 5082.67,5001.01 4678,4597.5C 4677.33,4570.5 4677.33,4543.5 4678,4516.5C 4958.51,4220.25 5144.51,3871.58 5236,3470.5C 5266.62,3332.15 5283.95,3192.15 5288,3050.5C 5288.67,2952.5 5288.67,2854.5 5288,2756.5C 5274.03,2327.96 5148.7,1935.96 4912,1580.5C 4840.97,1476.43 4761.97,1378.43 4675,1286.5C 4614.44,1225.28 4553.28,1164.78 4491.5,1105C 4183.56,822.983 3823.22,640.649 3410.5,558C 3280.35,533.017 3149.02,519.684 3016.5,518C 2926.49,517.13 2836.49,517.463 2746.5,519C 2322.84,534.563 1935.17,659.23 1583.5,893C 1477.81,964.652 1378.47,1044.65 1285.5,1133C 1231.31,1186.86 1177.47,1241.03 1124,1295.5C 833.472,1604.5 645.472,1968.5 560,2387.5C 536.384,2508.05 522.717,2629.71 519,2752.5C 516.521,2869.52 517.188,2986.52 521,3103.5C 546.733,3545.78 689.066,3945.11 948,4301.5C 1002.24,4373.76 1060.24,4443.09 1122,4509.5C 1179.17,4568 1237,4625.83 1295.5,4683C 1613.47,4981.5 1988.47,5171.5 2420.5,5253C 2533.95,5273.31 2648.28,5284.98 2763.5,5288C 2856.17,5288.67 2948.83,5288.67 3041.5,5288C 3194.84,5284.25 3346.17,5264.92 3495.5,5230C 3523.83,5229.33 3552.17,5229.33 3580.5,5230C 3677.31,5325.81 3773.81,5421.97 3870,5518.5C 3870.67,5545.5 3870.67,5572.5 3870,5599.5C 3856.83,5612.67 3843.67,5625.83 3830.5,5639C 3548.25,5736.52 3257.92,5792.18 2959.5,5806C 2834.27,5807.82 2709.6,5800.15 2585.5,5783C 2047.38,5710.14 1562.72,5511.47 1131.5,5187C 1025.72,5106.92 925.548,5019.76 831,4925.5C 501.241,4573.58 265.908,4164.91 125,3699.5C 52.9929,3455.79 11.1596,3207.12 -0.5,2953.5C -0.5,2920.17 -0.5,2886.83 -0.5,2853.5C 23.7186,2342.55 164.552,1866.55 422,1425.5C 539.673,1227.78 677.339,1044.78 835,876.5C 894.77,816.716 956.936,759.883 1021.5,706C 1436.34,363.31 1910.34,142.977 2443.5,45C 2577.03,21.3673 2711.36,6.20066 2846.5,-0.5 Z"/></g>
                <g><path fill="currentColor" d="M 2859.5,1544.5 C 2888.84,1544.33 2918.17,1544.5 2947.5,1545C 3284.07,1575.86 3578.74,1701.52 3831.5,1922C 3884.23,1972.7 3931.73,2027.53 3974,2086.5C 4140.43,2317.37 4236.1,2575.37 4261,2860.5C 4261.67,2889.17 4261.67,2917.83 4261,2946.5C 4235.49,3233.44 4138.49,3492.77 3970,3724.5C 3956.17,3738.33 3942.33,3752.17 3928.5,3766C 3901.5,3766.67 3874.5,3766.67 3847.5,3766C 3760.33,3678.83 3673.17,3591.67 3586,3504.5C 3585.33,3477.17 3585.33,3449.83 3586,3422.5C 3679.8,3310.89 3732.46,3181.89 3744,3035.5C 3745.62,2952.85 3745.95,2870.18 3745,2787.5C 3735.97,2626.53 3678.3,2486.2 3572,2366.5C 3524.44,2316.94 3475.61,2268.77 3425.5,2222C 3306.83,2122.3 3169.49,2068.63 3013.5,2061C 2933.49,2060.06 2853.49,2060.39 2773.5,2062C 2614.29,2074.63 2476.29,2134.63 2359.5,2242C 2320.67,2280.83 2281.83,2319.67 2243,2358.5C 2129.19,2482.14 2068.52,2628.47 2061,2797.5C 2060.07,2875.18 2060.4,2952.84 2062,3030.5C 2072.45,3179.29 2125.45,3310.29 2221,3423.5C 2221.67,3450.5 2221.67,3477.5 2221,3504.5C 2133.5,3592 2046,3679.5 1958.5,3767C 1931.5,3767.67 1904.5,3767.67 1877.5,3767C 1864,3753.5 1850.5,3740 1837,3726.5C 1667.44,3494.17 1570.11,3233.84 1545,2945.5C 1544.33,2917.5 1544.33,2889.5 1545,2861.5C 1575.84,2521.99 1702.84,2224.99 1926,1970.5C 1963.11,1932.04 2002.61,1896.54 2044.5,1864C 2284.37,1678.81 2556.04,1572.31 2859.5,1544.5 Z"/></g>
              </svg>
              <p class={"text-center #{if @current_path == :quests, do: "font-bold", else: "font-base"}"}>Quests</p>
          </div>
          </.link>

          <.link patch="/profile" class={" #{if @current_path == :profile, do: "text-gray-900"} py-2 w-14 h-14 text-xs"}>

          <div>
            <!-- Replace with the appropriate icon HTML -->
            <span class={"ml-4 w-6 h-6 hero-user#{if @current_path == :profile, do: "-solid"}"}>
            </span>
            <p class={"text-center #{if @current_path == :profile, do: "font-bold", else: "font-base"}"}>Profile</p>
        </div>
        </.link>
        </div>
        </div>

    """
  end


  @doc """
    List badges
  """
  attr :quest_id, :string, required: true
  attr :quest_name, :string, required: true
  attr :quest_progress, :string, required: true
  attr :unlocked_badges, :string, required: true
  attr :total_badges, :string, required: true
  attr :quest_reward, :string, required: true
  attr :badge_image, :string, required: true
  attr :badge_name, :string, required: true

  def badge_accordion(assigns) do
    ~H"""
    Test
    """
  end

  @doc """
  rendering badges component
  """

  def badge_component(assigns) do
    ~H"""
    <div
      class={assigns[:class]}
      data-redirect-url={assigns[:badge_details_image]}
      data-badge-description={assigns[:badge_description]}
      data-is-user-badge={assigns[:is_user_badge]}
    >
      <!-- Badge image and name -->
      <img src={assigns[:image]} alt={assigns[:name]} class="rounded-full badge-neo" />
      <p class="mt-2 text-xs text-center text-slate-700"><%= assigns[:name] %></p>
    </div>
    """
  end

  @doc """
  create a
  """

  def find_quests(assigns) do
    ~H"""
    <a class="flex mx-auto w-10/12 bg-white rounded-lg shadow-md text-slate-600" href="/new">
      <img class="my-auto ml-2 w-10 h-10" src="/images/PurpleQuestLogo.svg" />

      <p class="flex-grow py-4 text-xl text-center">
        Find a Quest
      </p>

      <span class="my-auto mr-2 animate-pulse hero-chevron-right" />
    </a>
    """
  end

  @doc """
    the stat bubbles
  """
  attr :text, :string, required: true
  attr :color, :string, required: true
  attr :number, :string, required: true

  def stats_bubble(assigns) do
    ~H"""
    <div class="">
      <div class={"mx-auto bg-#{@color}-200 border-2 shadow-lg border-#{@color}-500 flex justify-center items-center rounded-full h-14 w-14"}>
        <p class="font-semibold text-slate-700">
          <%= @number %>
        </p>
      </div>

      <p class="mt-2 text-sm font-light text-center text-slate-700">
        <%= @text %>
      </p>
    </div>
    """
  end

  @doc """
  Google sign in approved button
  """

  def google(assigns) do
    ~H"""
    <a href="/auth/google">
      <div class="mx-auto gsi-material-button">
        <div class="gsi-material-button-state"></div>
        <div class="gsi-material-button-content-wrapper">
          <div class="gsi-material-button-icon">
            <svg
              version="1.1"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 48 48"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              style="display: block;"
            >
              <path
                fill="#EA4335"
                d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"
              >
              </path>
              <path
                fill="#4285F4"
                d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"
              >
              </path>
              <path
                fill="#FBBC05"
                d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"
              >
              </path>
              <path
                fill="#34A853"
                d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"
              >
              </path>
              <path fill="none" d="M0 0h48v48H0z"></path>
            </svg>
          </div>
          <span class="gsi-material-button-contents">Sign in with Google</span>
          <span style="display: none;">Sign in with Google</span>
        </div>
      </div>
    </a>
    """
  end

  @doc """
  renders the concentric circles

  """

  attr :width, :string, required: true
  attr :border, :string, required: true
  attr :glow, :boolean, default: false

  def circles(assigns) do
    ~H"""
    <!-- Inner concentric circles -->
    <div class={" #{calculate_glow(assigns)} h-#{@width} w-#{@width} bg-brand rounded-full
      flex items-center justify-center relative"}>
      <div class={"absolute rounded-full border-#{@border} border-white h-3/4 w-3/4"}></div>
      <div class={"absolute rounded-full border-#{@border} border-white h-2/5 w-2/5"}></div>
    </div>
    """
  end

  defp calculate_glow(assigns) do
    if assigns.glow, do: "glow-button mx-auto"
  end

  @doc """
  Renders reward pill

  <.reward text="test" color="green" />

  Then put that compiled style in the tailwindconfig file under safelist
  as the styles will not be compiled
  """
  attr :text, :string, required: true
  attr :color, :string, required: true

  def reward(assigns) do
    ~H"""
    <div class={"p-1 inline-flex text-#{@color}-600 bg-#{@color}-100 rounded-lg"}>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="my-auto ml-2 w-4 h-full"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M16.5 18.75h-9m9 0a3 3 0 0 1 3 3h-15a3 3 0 0 1 3-3m9 0v-3.375c0-.621-.503-1.125-1.125-1.125h-.871M7.5 18.75v-3.375c0-.621.504-1.125 1.125-1.125h.872m5.007 0H9.497m5.007 0a7.454 7.454 0 0 1-.982-3.172M9.497 14.25a7.454 7.454 0 0 0 .981-3.172M5.25 4.236c-.982.143-1.954.317-2.916.52A6.003 6.003 0 0 0 7.73 9.728M5.25 4.236V4.5c0 2.108.966 3.99 2.48 5.228M5.25 4.236V2.721C7.456 2.41 9.71 2.25 12 2.25c2.291 0 4.545.16 6.75.47v1.516M7.73 9.728a6.726 6.726 0 0 0 2.748 1.35m8.272-6.842V4.5c0 2.108-.966 3.99-2.48 5.228m2.48-5.492a46.32 46.32 0 0 1 2.916.52 6.003 6.003 0 0 1-5.395 4.972m0 0a6.726 6.726 0 0 1-2.749 1.35m0 0a6.772 6.772 0 0 1-3.044 0"
        />
      </svg>

      <h1 class="text-[13px] my-auto mx-2"><%= @text %></h1>
    </div>
    """
  end

  @doc """
  Renders a location with link to maps of that location

  ## Examples

  <.location text="Luna" url="https:/googlemaps.com"
  """

  attr :text, :string, required: true
  attr :url, :string, default: nil

  def location(assigns) do
    ~H"""
    <a class="my-2 text-slate-500" href={@url}>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1"
        stroke="currentColor"
        class="inline w-4 h-4"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
        />
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"
        />
      </svg>
      <span class="my-auto text-xs">
        <%= @text %>
      </span>
    </a>
    """
  end

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="hidden relative z-50"
    >
      <div id={"#{@id}-bg"} class="fixed inset-0 transition-opacity bg-zinc-50/90" aria-hidden="true" />
      <div
        class="overflow-y-auto fixed inset-0"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex justify-center items-center min-h-full">
          <div class="p-4 w-full max-w-3xl sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="hidden relative p-14 bg-white rounded-2xl ring-1 shadow-lg transition shadow-zinc-700/10 ring-zinc-700/10"
            >
              <div class="absolute right-5 top-6">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="flex-none p-3 -m-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class="w-5 h-5" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <%= render_slot(@inner_block) %>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: "flash", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed top-2 right-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex gap-1.5 items-center text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="w-4 h-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="w-4 h-4" />
        <%= @title %>
      </p>
      <p class="mt-2 text-sm leading-5"><%= msg %></p>
      <button type="button" class="absolute top-1 right-1 p-2 group" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="w-5 h-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  def flash_group(assigns) do
    ~H"""
    <.flash kind={:info} title="Success!" flash={@flash} />
    <.flash kind={:error} title="Error!" flash={@flash} />
    <.flash
      id="client-error"
      kind={:error}
      title="We can't find the internet"
      phx-disconnected={show(".phx-client-error #client-error")}
      phx-connected={hide("#client-error")}
      hidden
    >
      Attempting to reconnect <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
    </.flash>

    <.flash
      id="server-error"
      kind={:error}
      title="Something went wrong!"
      phx-disconnected={show(".phx-server-error #server-error")}
      phx-connected={hide("#server-error")}
      hidden
    >
      Hang in there while we get back on track
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
    </.flash>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="mt-10 space-y-8 bg-transparent">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="flex gap-6 justify-between items-center mt-2">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox", value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class="flex gap-4 items-center text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
          {@rest}
        />
        <%= @label %>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class="block mt-2 w-full bg-white rounded-md border border-gray-300 shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "min-h-[6rem] phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="flex gap-3 mt-3 text-sm leading-6 text-rose-600 phx-no-feedback:hidden">
      <.icon name="hero-exclamation-circle-mini" class="flex-none mt-0.5 w-5 h-5" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="w-[40rem] mt-11 sm:w-full">
        <thead class="text-sm leading-6 text-left text-zinc-500">
          <tr>
            <th :for={col <- @col} class="p-0 pr-6 pb-4 font-normal"><%= col[:label] %></th>
            <th class="relative p-0 pb-4"><span class="sr-only"><%= gettext("Actions") %></span></th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative text-sm leading-6 border-t divide-y divide-zinc-100 border-zinc-200 text-zinc-700"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div class="block py-4 pr-6">
                <span class="absolute right-0 -inset-y-px -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  <%= render_slot(col, @row_item.(row)) %>
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative p-0 w-14">
              <div class="relative py-4 text-sm font-medium text-right whitespace-nowrap">
                <span class="absolute left-0 -inset-y-px -right-4 group-hover:bg-zinc-50 sm:rounded-r-xl" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  <%= render_slot(action, @row_item.(row)) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="flex-none w-1/4 text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" class="w-3 h-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from your `assets/vendor/heroicons` directory and bundled
  within your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  @doc """
  Renders the bottom navbar icons text

  ## Examples

  <.bottom_nav page_name="home" icon="home" />
  """
  attr :url, :string, required: true
  attr :request_path, :string, required: true
  attr :page_name, :string, required: true
  attr :icon, :string, required: true

  def bottom_nav(assigns) do
    ~H"""
    <a href={@url} class="py-2">
      <div class={calculate_class(assigns)}>
        <.icon name={"hero-#{@icon}"} class="ml-1 w-7 h-7" />
        <p class="text-sm text-center"><%= @page_name %></p>
      </div>
    </a>
    """
  end

  defp calculate_class(assigns) do
    if assigns.request_path == assigns.url, do: "text-violet-700", else: "text-slate-700"
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(QuestApiV21Web.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(QuestApiV21Web.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  ## Avatar
  # <!-- font-sans, text-black, and bg-purple-500 can be changed to change the look of the avatar -->

  attr :name, :string, required: true
  attr :class, :string, default: nil

  def avatar(assigns) do
    initialsList = String.split(assigns.name)
    assigns = assign(assigns, :initialsList, initialsList)

    ~H"""
    <div
      class="inline-flex justify-center items-center w-24 h-24 font-sans text-5xl text-black bg-purple-500 rounded-full shadow-xl"
      style="border:1px solid black; border-radius: 50%; overflow: hidden; text-overflow: ellipsis;"
    >
      <%= for name <- @initialsList do %>
        <%= String.first(name) %>
      <% end %>
    </div>
    """
  end

  attr :buttonTitle, :string, required: true
  attr :contentID, :string, required: true
  slot :inner_block, required: true

  @spec accordionButton(map()) :: Phoenix.LiveView.Rendered.t()
  def accordionButton(assigns) do
    ~H"""
    <style>
      #accordionContentPasswordID {
        height: 0;
        overflow: hidden;
        transition: height 0.3s ease-out;
      }
    </style>

    <script>
       function toggleAccordion(contentId, chevronId) {
        var content = document.getElementById(contentId);
        var chevron = document.getElementById(chevronId);

        if (content.style.height === '0px' || content.style.height === '') {
          content.style.height = content.scrollHeight + 'px';
        } else {
          content.style.height = '0px';
        }

        chevron.classList.toggle('rotate-90');
      }
    </script>

    <h6
      class="mb-0"
      onclick={"toggleAccordion('accordionContent#{assigns.contentID}', 'accordionChevron#{assigns.contentID}')"}
    >
      <button
        class="flex relative justify-between items-center p-4 w-full font-semibold text-left border-b border-solid transition-all ease-in cursor-pointer border-slate-100 text-slate-700 rounded-t-1 group text-dark-500"
        data-collapse-target="animated-collapse-1"
      >
        <span><%= assigns.buttonTitle %></span>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="right-0 w-6 h-6 text-base transition-transform fa fa-chevron-down group-open:rotate-90"
          id={"accordionChevron#{assigns.contentID}"}
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
        </svg>
      </button>
    </h6>

    <%= render_slot(@inner_block) %>
    """
  end
end
