module ApplicationHelper

  # En hjälpmetod för att lägga till information i titeln
  def title(title = nil)
    if title.present?
      content_for :title, title
    else
      content_for?(:title) ? content_for(:title)  + ' | ' + APP_CONFIG['default_title'] : APP_CONFIG['default_title']
    end
  end

  # En hjälpmetod för att lägga till meta-author
  def meta_author(authors = nil)
    if authors.present?
      content_for :meta_author, authors
    else
      content_for?(:meta_author) ? [content_for(:meta_author), APP_CONFIG['meta_author']].join(', ') : APP_CONFIG['meta_author']
    end
  end

  # En hjälpmetod för att lägga till meta-keywords
  def meta_keywords(tags = nil)
    if tags.present?
      content_for :meta_keywords, tags
    else
      content_for?(:meta_keywords) ? [content_for(:meta_keywords), APP_CONFIG['meta_keywords']].join(', ') : APP_CONFIG['meta_keywords']
    end
  end

  # En hjälpmetod för att lägga till meta-description
  def meta_description(desc = nil)
    if desc.present?
      content_for :meta_description, desc
    else
      content_for?(:meta_description) ? content_for(:meta_description) : APP_CONFIG['meta_description']
    end
  end

  def followed_maps
    @maps = []
    # Hämtar alla Follow-objekt som är kopplad till current_user...
    Follow.find_all_by_follower_id_and_followable_type(current_user.id, 'Map').each do |follow|
      # ... hämtar den kartan som menas
      @maps << Map.find(follow.followable_id)
    end

    return @maps
  end

  ##
  # Like räknare.
  # Räknar antalet användare som gillar ett likable-objekt
  # och returnerar olika svar.
  # Möjliga svar är:
  # Du och en person till...
  # Du och :nr personer...
  # :nr personer...
  # Du...
  # 1 person...
  # ...gillar detta
  #
  # @param Likable
  # @return String
  def like_count_string(likable)
    @count = likable.likers(User).count
    @user_likes = current_user.likes?(likable)
    @count_string = ""

    # kontrollerar först om någon gillar...
    if @count > 0

      # ... om fler än en person gillar...
      if @count > 1

        # ...  och användaren är en av dom
        if @user_likes

          # ... om användaren och en till person gillar
          if @count == 2
            @count_string = "Du och #{ @count - 1 } person till"
          else
            @count_string = "Du och #{ @count - 1 } presoner till"
          end

        else
          @count_string = "#{ @count } personer"
        end
      # ... om det inte är fler än en person som gillar och användaren är en av dom
      elsif @user_likes
        @count_string = "Du"
      else
        @count_string = "#{ @count } person"
      end
      @count_string += " gillar detta"
    end
  end


  ##
  # DateTime formaterare
  # Möjliga svar:
  # idag kl. hh:mm
  # igår kl. hh:mm
  # den :date_nr :month kl. hh:mm
  # den :date_nr :month :year kl. hh:mm
  #
  # @@param DateTime
  # @return string

  def time_ago(time_format = nil)
    now = Time.now
    time = time_format
    months = ["Januari", "Februari", "Mars","April", "Maj", "Juni", "Juli", "Augusti", "September", "Oktober", "November", "December"]
    month = months[time.month - 1]

    # Är det idag?
    if time.today?
      time.strftime("idag kl. %H:%M")

      # Är det igar?
    elsif time.day == now.yesterday.day
      time.strftime("igar kl. %H:%M")

      # Är det iår?
    elsif time.year == now.year
      time.strftime("den %d "+ month +" kl. %H:%M")

    else
      time.strftime("den %d "+ month +" %Y kl. %H:%M")
    end
  end

  # Gör om text-baserade smilies till...span-taggar som kan ändras efter behov
  def format_text(text)
    # HTML-escapar strängen så script-taggar och annat okul inte visas på sajten
    text = ERB::Util::html_escape(text)
    puts "&lt;3"
    # Byter ut smilies till spantaggar
    text.gsub!(/\:\-?\)/, '<span class="emoticon smile"></span><span class="hide">:)</span>')
    #text.gsub!(/\:\-?\D/, '<span class="emoticon big-smile"></span><span class="hide">:D</span>')
    #text.gsub!(/\=\-?\)/, '<span class="emoticon smile"></span><span class="hide">=)</span>')
    text.gsub!(/\;\-?\)/, '<span class="emoticon wink"></span><span class="hide">;)</span>')
    text.gsub!(/\&lt;3/, '<span class="emoticon heart"></span><span class="hide"><3</span>')
    text.gsub!(/\:\-?\(/, '<span class="emoticon sad"></span><span class="hide">:(</span>')

    # Markerar strängen som HTML-safe (eftersom den är icke-safe med span-taggar i sig)
    text.html_safe
  end
end
