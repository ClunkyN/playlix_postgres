# =========================
# LOGIN UI (FINAL – SVG EYE TOGGLE)
# =========================
login_ui <- tagList(
  
  # =========================
  # HEAD (CSS + JS)
  # =========================
  tags$head(
    
    tags$style(HTML("
      html, body {
        margin: 0 !important;
        padding: 0 !important;
        width: 100vw !important;
        height: 100vh !important;
        background: black !important;
      }

     .login-wrapper {
    position: fixed;
    inset: 0;
    width: 100vw;
    height: 100vh;
    background: black;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden; 
  }

      .login-box {
        width: 360px;
        padding: 30px;
        background: #0f0f0f;
        border-radius: 14px;
        box-shadow: 0 0 25px rgba(229,9,20,0.7);
        text-align: center;
      }

      .login-box input {
        width: 100% !important;
      }

      .password-wrap {
        position: relative;
      }

      .eye-btn {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        cursor: pointer;
        width: 22px;
        height: 22px;
        color: #e50914;
        z-index: 20;
      }

      .eye-btn svg {
        width: 22px;
        height: 22px;
        display: block;
      }

      .eye-btn svg path {
        stroke: currentColor !important;
        fill: none !important;
      }
    ")),
    
    tags$script(HTML("
      function togglePassword() {
        const input = document.getElementById('login_pass');
        const icon  = document.getElementById('eye_icon');
        if (!input || !icon) return;

        if (input.type === 'password') {
          input.type = 'text';
          icon.innerHTML = document.getElementById('eye_closed_svg').innerHTML;
        } else {
          input.type = 'password';
          icon.innerHTML = document.getElementById('eye_open_svg').innerHTML;
        }
      }
    "))
  ),
  
  # =========================
  # LOGIN SCREEN
  # =========================
  div(
    class = "login-wrapper",
    
    div(
      class = "login-box",
      
      h2("🔐 PLAYLIX LOGIN",
         style = "color:#e50914;margin-bottom:25px;"),
      
      # USERNAME
      textInput("login_user", NULL, placeholder = "Username"),
      
      # PASSWORD + EYE
      div(
        class = "password-wrap",
        
        passwordInput("login_pass", NULL, placeholder = "Password"),
        
        tags$span(
          id = "eye_icon",
          class = "eye-btn",
          onclick = "togglePassword()",
          HTML("
            <svg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'>
              <path d='M21.92,11.6C19.9,6.91,16.1,4,12,4S4.1,6.91,2.08,11.6a1,1,0,0,0,0,.8C4.1,17.09,7.9,20,12,20s7.9-2.91,9.92-7.6A1,1,0,0,0,21.92,11.6Z'/>
              <circle cx='12' cy='12' r='4'/>
              <circle cx='12' cy='12' r='2'/>
            </svg>
          ")
        )
      ),
      
      # LOGIN BUTTON
      actionButton(
        "login_btn",
        "LOGIN",
        style = "
          width:100%;
          margin-top:20px;
          background:#e50914;
          color:white;
          font-size:18px;
          border:none;
          padding:12px;
          border-radius:6px;
        "
      ),
      
      # ERROR MESSAGE
      uiOutput("login_error")
    )
  ),
  
  # =========================
  # HIDDEN SVG TEMPLATES
  # =========================
  tags$div(style = "display:none;",
           
           # OPEN EYE
           tags$div(id = "eye_open_svg", HTML("
      <svg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'>
        <path d='M21.92,11.6C19.9,6.91,16.1,4,12,4S4.1,6.91,2.08,11.6a1,1,0,0,0,0,.8C4.1,17.09,7.9,20,12,20s7.9-2.91,9.92-7.6A1,1,0,0,0,21.92,11.6Z'/>
        <circle cx='12' cy='12' r='4'/>
        <circle cx='12' cy='12' r='2'/>
      </svg>
    ")),
           
           # CLOSED EYE (YOUR SVG)
           tags$div(id = "eye_closed_svg", HTML("
      <svg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'>
        <path d='M2 10C2 10 5.5 14 12 14C18.5 14 22 10 22 10'
          stroke-width='2' stroke-linecap='round' stroke-linejoin='round'/>
        <path d='M4 11.6445L2 14' stroke-width='2' stroke-linecap='round'/>
        <path d='M22 14L20.0039 11.6484' stroke-width='2' stroke-linecap='round'/>
        <path d='M8.91406 13.6797L8 16.5' stroke-width='2' stroke-linecap='round'/>
        <path d='M15.0625 13.6875L16 16.5' stroke-width='2' stroke-linecap='round'/>
      </svg>
    "))
  )
)

# =========================
# LOGIN SERVER (FIXED)
# =========================
login_server <- function(input, output, session, logged_in) {
  
  # Add JavaScript to handle login state persistence
  insertUI(
    selector = "body",
    where = "beforeEnd",
    ui = tags$script(HTML("
      Shiny.addCustomMessageHandler('checkLoginState', function(msg) {
        // Check if already logged in from sessionStorage
        if (sessionStorage.getItem('playlix_logged_in') === 'true') {
          Shiny.setInputValue('restore_login_state', true);
        }
      });
      
      Shiny.addCustomMessageHandler('setLoggedIn', function(msg) {
        sessionStorage.setItem('playlix_logged_in', 'true');
      });
      
      Shiny.addCustomMessageHandler('clearLoginState', function(msg) {
        sessionStorage.removeItem('playlix_logged_in');
      });
    ")),
    immediate = TRUE
  )
  
  # 🔐 LOGIN LOGIC
  observeEvent(input$login_btn, {
    
    if (
      input$login_user == "Clunky" &&
      input$login_pass == "Thisistheplaylixpassword!087"
    ) {
      logged_in(TRUE)
      # Notify JavaScript to save login state to sessionStorage
      session$sendCustomMessage("setLoggedIn", list())
    } else {
      output$login_error <- renderUI({
        div(
          "❌ Invalid username or password",
          style="color:#e50914;margin-top:15px;font-weight:bold;"
        )
      })
    }
    
  }, ignoreInit = TRUE)
  
}
