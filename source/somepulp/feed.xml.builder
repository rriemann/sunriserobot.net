---
blog: "Some Pulp"
---
@show_data       = YAML.load_file("source/data/shows.yml").find { |s| s["prefix"] == blog.options.prefix.sub("/", "") }
@rss_boilerplate = YAML.load_file("source/data/rss-boilerplate.yml")["rss_boilerplate"]
@host_names      = @show_data["hosts"].map { |host| host["name"] }.join(" and ")
@album_art_url   = "http://sunriserobot.net/images/#{@show_data["large_art"]}"
