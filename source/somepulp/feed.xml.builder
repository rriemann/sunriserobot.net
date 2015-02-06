---
blog: "Some Pulp"
---
show_data       = YAML.load_file("source/data/shows.yml").find { |s| s["prefix"] == blog.options.prefix.sub("/", "") }
rss_boilerplate = YAML.load_file("source/data/rss-boilerplate.yml")["rss_boilerplate"]
host_names      = show_data["hosts"].map { |host| host["name"] }.join(" and ")
album_art_url   = "http://sunriserobot.net/images/#{show_data["large_art"]}"

xml.instruct!
xml.rss "xmlns:dc"      => "http://purl.org/dc/elements/1.1/",
        "xmlns:sy"      => "http://purl.org/rss/1.0/modules/syndication/",
        "xmlns:admin"   => "http://webns.net/mvcb/",
        "xmlns:atom"    => "http://www.w3.org/2005/Atom/",
        "xmlns:rdf"     => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
        "xmlns:itunes"  => "http://www.itunes.com/dtds/podcast-1.0.dtd",
        "version"       => "2.0" do
  xml.channel do
    site_url = "http://sunriserobot.net/#{show_data["prefix"]}"
    xml.title show_data["title"]
    xml.link site_url # Link to show page, not a specific episode
    xml.description show_data["description"]
    xml.language "en-us"
    xml.copyright "Copyright #{Time.now.year} Sunrise Robot"
    xml.image do
      xml.url album_art_url
      xml.title show_data["title"]
      xml.link site_url
    end
    # iTunes specific
    xml.tag! "itunes:new-feed-url", "http://sunriserobot.net/#{show_data["prefix"]}/feed.xml"
    xml.tag! "itunes:subtitle", show_data["title"]
    xml.tag! "itunes:author", "Sunrise Robot"
    xml.tag! "itunes:summary", show_data["description"]
    xml.tag! "itunes:image href=\"#{album_art_url}\""
    xml.tag! "itunes:explicit", "No"
    xml.tag! "itunes:owner" do
      xml.tag! "itunes:name", "Sunrise Robot"
      xml.tag! "itunes:email", show_data["email"]
    end
    xml.tag! "itunes:category", "text" => show_data["category"]

    # Item builder
    blog.articles[0..9].each do |episode|
      xml.item do
      link = URI.join(site_url, episode.url)
        xml.title "#{episode.data.number} - #{episode.data.title}"
        xml.link link
        xml.guid link
        xml.pubDate episode.date.httpdate
        xml.author host_names
        xml.description episode.data.description
        xml.enclosure "url" => episode.data.enclosure_link,
                      "length" => episode.data.enclosure_length,
                      "type" => "audio/mpeg"
        rss_boilerplate = rss_boilerplate % { :LINK => link,
                                              :SHOW_TITLE => show_data["title"],
                                              :SHOW_HOSTS => host_names,
                                              :ITUNES_LINK => show_data["itunes"] }

        xml.tag! "content:encoded",
                 "<p>#{episode.data.description}</p>"\
                 "<h1>Show Notes</h1>"\
                 "#{episode.body}"\
                 "\n#{rss_boilerplate}"
        xml.tag! "itunes:author", host_names
        xml.tag! "itunes:duration", episode.data.duration
        xml.tag! "itunes:subtitle", episode.data.description
        xml.tag! "itunes:summary", episode.data.description
        xml.tag! "itunes:image", "href" => album_art_url
      end
    end
  end
end
