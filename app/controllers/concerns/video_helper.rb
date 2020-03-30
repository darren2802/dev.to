module VideoHelper
  def youtube_videos(tags)
    videos = GoogleService.youtube_videos(tags)
    videos.delete_if { |video| video[:id][:videoId].nil? }
    videos_abridged = videos_relevant_recent(videos, 3, 3)

    video_ids = videos_abridged.map { |video| video[:id][:videoId] }
    id_string = video_ids.join(",")
    video_data = GoogleService.video_data(id_string)

    videos_abridged.map do |video|
      statistics = video_data.detect { |video_d| video_d[:id] == video[:id][:videoId] }
      YoutubeVideo.new(video, statistics)
    end
  end

  def videos_relevant_recent(videos, nr_relevant, nr_recent)
    most_relevant = videos[0..(nr_relevant - 1)]
    most_recent = videos_recent(videos, most_relevant, nr_recent)
    most_relevant.concat(most_recent)
  end

  def videos_recent(videos, most_relevant, nr_recent)
    counter = 0
    most_recent = []
    sorted = videos.sort_by { |video| video[:snippet][:publishedAt] }.reverse

    sorted.each do |video|
      if most_relevant.none? { |video_relevant| video_relevant == video }
        most_recent << video
        counter += 1
        break if counter == nr_recent
      end
    end
    most_recent
  end
end
