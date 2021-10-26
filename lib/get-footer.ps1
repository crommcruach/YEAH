function get-footer()
{
    $footer = get-content("$(resolve-path $script:config.HtmlFolder)\footer.html")
    return $footer
}