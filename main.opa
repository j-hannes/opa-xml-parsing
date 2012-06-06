Server.start(
  Server.http,
  {title: "server_call"
  ,page: main
  }
)

function main() {
  rpc_method = "get_server_info"
  rpc_params = ""

  xml request_body = @xml(
    <methodCall>
      <methodName>{rpc_method}</methodName>
      <params>{rpc_params}</params>
    </methodCall>
  )

  <div id=#response_data
       onready={function(_){send_request(request_body)}}>
    CONNECTING...
  </div>
}

exposed function send_request(xml request_body) {
  request =
    WebClient.Post.of_xml(
      {WebClient.Post.default_options with
        content: {some: request_body}
      }
    )

  WebClient.Post.try_post_with_options_async(
    autotool_service_uri,
    request,
    server_callback_2
  )
}

autotool_service_uri =
  Uri.of_absolute(
    {Uri.default_absolute with
      domain: "autolat.imn.htwk-leipzig.de",
      path: ["cgi-bin", "autotool-0.2.1.cgi"]
    }
  )

function server_callback_1(response){
  match (WebClient.Result.as_xml(response)) {
    case {success: result}:
      #response_data = <span>{result}</span>

    case {failure: f}:
      #response_data = <span class="error">{f}</span>
  }
}

function server_callback_2(response){
  match(response) {
    case {failure: _}:
      #response_data =
        <span class="error">Error: Could not reach the remote server</span>

    case {success: s}:
      match (WebClient.Result.get_class(s)) {
        case {success}:

          match (Xmlns.try_parse(s.content)) {
            case {some: result}:
              // process xml
              // ...

              // testwise just create an output
              #response_data = <span>{result}</span>

            default:
              #response_data =
                <span style={red_style}>could not parse xml response:</span>
                <span>{s.content}</span>
          }

        default:
          #response_data = <span style={red_style}>Error: {s.code}</span>
      }
  }
}

red_style = css {color: red;}
