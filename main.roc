app [main!] { cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/Hj-J_zxz7V9YurCSTFcFdu6cQJie4guzsPMUi5kBYUk.tar.br" }

import cli.Stdout
import cli.Stdin
import cli.Http
import cli.File

platform_url_placeholder = "<platform-url>"
release_urls = {
    cli: "https://github.com/roc-lang/basic-cli/releases/download/0.12.0/Lb8EgiejTUzbggO2HVVuPJFkwvvsfW6LojkLR20kTVE.tar.br",
    web: "https://github.com/roc-lang/basic-webserver/releases/download/0.12.0/Q4h_In-sz1BqAvlpmCsBHhEJnn_YvfRRMiNACB_fBbk.tar.br",
}

file_template_urls = {
    cli: "https://raw.githubusercontent.com/nkxxll/roc-init/refs/heads/master/assets/cli-main.roc.template",
    web: "https://raw.githubusercontent.com/nkxxll/roc-init/refs/heads/master/assets/web-main.roc.template",
}

get_template_file! = |config|
    file =
        when config.application_type is
            Cli -> Http.get_utf8!(file_template_urls.cli)?
            WebServer -> Http.get_utf8!(file_template_urls.web)?
    Ok file

replace_platform = |file_contents, config|
    when config.application_type is
        Cli -> file_contents |> Str.replace_first(platform_url_placeholder, release_urls.cli)
        WebServer -> file_contents |> Str.replace_first(platform_url_placeholder, release_urls.web)

write_to_main! = |file_content|
    File.write_utf8!(file_content, "main.roc")

ask_type! = |{}|
    Stdout.line!("Enter the app type [C]li | [W]ebServer [default: Cli]")?
    line = Stdin.line!({}) |> Result.with_default("")
    when line is
        "" | "C" | "Cli" -> Ok Cli
        "W" | "WebServer" -> Ok WebServer
        _ ->
            (
                Stdout.line!("${line} not an option enter a valid option!")?
                ask_type!({})
            )

app_type_str = |app_type|
    when app_type is
        Cli -> "Cli"
        WebServer -> "WebServer"

config_str = |config|
    at = app_type_str(config.application_type)
    "\n===Config===\n" |> Str.concat "Type: ${at}\n"

main! = |_args|
    app_type = ask_type!({})?
    c = { application_type: app_type }
    c_str = config_str(c)
    file_contents = c |> get_template_file!()?
    file_contents |> replace_platform(c) |> write_to_main!()?
    Stdout.line!("Created: main.roc with ${app_type_str(app_type)} template")?
    Stdout.line!("Config to string is ${c_str}")
