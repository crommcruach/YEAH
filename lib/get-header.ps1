function get-header()
{
    $header = get-content("$(resolve-path $script:config.HtmlFolder)\header.html")
    return $header
}