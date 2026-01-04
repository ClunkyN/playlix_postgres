let hideTimer = null;

Shiny.addCustomMessageHandler("pageView", function (v) {
  Shiny.setInputValue("current_page_view", v, { priority: "event" });
});

/* ================= GLOBAL CLICK LOCK (PREVENT DOUBLE CLICK) =================
   - Locks only important action buttons so one click = one input.
   - DOES NOT lock episode panel toggles (so Select Ep can open/close normally).
   - Auto-unlocks if Shiny re-renders the UI or if button disappears.
============================================================================= */
(function () {
  const LOCK_MS = 800;

  function shouldLock(btn) {
    if (!btn) return false;

    // NEVER lock the panel toggle button; user must be able to open/close it
    if (btn.classList.contains("select-ep-btn")) return false;

    // Lock only your action buttons (avoid interfering with random bootstrap controls)
    return (
      btn.classList.contains("play-btn") ||
      btn.classList.contains("save-btn") ||
      btn.classList.contains("btn-success") ||
      btn.classList.contains("btn-danger") ||
      btn.classList.contains("favorite-btn") ||
      btn.classList.contains("logout-btn") ||
      btn.classList.contains("add-button") ||
      btn.classList.contains("episode-btn") ||
      btn.classList.contains("back-btn") ||
      btn.classList.contains("page-btn")
    );
  }

  function lockButton(btn) {
    btn.dataset.clickLocked = "1";
    btn.dataset.wasDisabled = btn.disabled ? "1" : "0"; // preserve original disabled state
    btn.disabled = true;

    // Unlock after cooldown (only if the same button still exists)
    setTimeout(() => {
      if (!btn.isConnected) return; // removed by Shiny; ignore
      unlockButton(btn);
    }, LOCK_MS);
  }

  function unlockButton(btn) {
    // restore original disabled state
    const wasDisabled = btn.dataset.wasDisabled === "1";
    btn.disabled = wasDisabled;
    btn.dataset.clickLocked = "0";
    delete btn.dataset.wasDisabled;
  }

  // Capture-phase click handler to block double clicks early
  document.addEventListener(
    "click",
    function (e) {
      const btn = e.target.closest("button");
      if (!shouldLock(btn)) return;

      // already locked -> block extra clicks
      if (btn.dataset.clickLocked === "1") {
        e.preventDefault();
        e.stopPropagation();
        return false;
      }

      lockButton(btn);
    },
    true
  );

  // Safety: when Shiny re-renders, release any stuck locks
  document.addEventListener("shiny:recalculated", function () {
    document.querySelectorAll("button[data-click-locked='1']").forEach((btn) => {
      if (!btn.isConnected) return;
      unlockButton(btn);
    });
  });

  // Safety: on any modal close, release locks inside modal footer (prevents stuck disabled buttons)
  document.addEventListener("hidden.bs.modal", function () {
    document.querySelectorAll("button[data-click-locked='1']").forEach((btn) => {
      if (!btn.isConnected) return;
      unlockButton(btn);
    });
  });
})();

/* ================= PLAYER CONTROLS ================= */

function showControls() {
  const header = document.querySelector(".play-header");
  const episodes = document.querySelector(".episode-nav");
  const title = document.querySelector(".episode-title");
  const selector = document.querySelector(".player-selector"); // optional
  const selectEp = document.querySelector(".select-ep-wrapper");

  if (header) header.classList.remove("hidden");
  if (episodes) episodes.classList.remove("hidden");
  if (title) title.classList.remove("hidden");
  if (selector) selector.classList.remove("hidden");
  if (selectEp) selectEp.classList.remove("hidden");

  if (hideTimer) clearTimeout(hideTimer);
  hideTimer = setTimeout(() => {
    if (header) header.classList.add("hidden");
    if (episodes) episodes.classList.add("hidden");
    if (title) title.classList.add("hidden");
    if (selector) selector.classList.add("hidden");
    if (selectEp) selectEp.classList.add("hidden");
  }, 2000);
}

/* ================= SHOW CONTROLS ON MOUSE MOVE ================= */

document.addEventListener("mousemove", function (e) {
  const overlay = document.getElementById("player-overlay");
  if (overlay && overlay.contains(e.target)) {
    showControls();
  }
});

/* ================= TOGGLE EPISODE PANEL ================= */

document.addEventListener("click", function (e) {
  const btn = e.target.closest(".select-ep-btn");
  if (!btn) return;

  const panel = document.getElementById("episode-panel");
  if (panel) panel.classList.toggle("hidden");
});

/* ================= 🎞 PAUSE YOUTUBE TRAILER ================= */

function pauseTrailer() {
  const frames = document.querySelectorAll("iframe[id^='trailer_iframe_']");

  frames.forEach(function (frame) {
    if (!frame.contentWindow) return;

    frame.contentWindow.postMessage(
      JSON.stringify({
        event: "command",
        func: "pauseVideo",
        args: [],
      }),
      "*"
    );
  });
}

/* ================= MODAL + SCROLL FIX ================= */

(function () {
  const originalSetProperty = document.body.style.setProperty;
  document.body.style.setProperty = function (property, value, priority) {
    if (property === "padding-right") return;
    originalSetProperty.call(this, property, value, priority);
  };
})();

// ❤️ Toggle favorite heart instantly (UI only)
function toggleFavorite(btn) {
  btn.classList.toggle("active");
  btn.innerHTML = btn.classList.contains("active") ? "&#10084;" : "&#9825;";
}

function resetBodyLayout() {
  document.body.classList.remove("modal-open");
  document.body.style.paddingRight = "0px";
  document.body.style.marginRight = "0px";
  document.body.style.overflow = "";
  document.querySelectorAll(".modal-backdrop").forEach((b) => b.remove());
}

$(document).on("shown.bs.modal", resetBodyLayout);

$(document).on("shiny:recalculated", function () {
  document.body.style.paddingRight = "0px";
  document.body.style.marginRight = "0px";
  document.body.style.overflowX = "hidden";
  document.documentElement.style.overflowX = "hidden";
});
