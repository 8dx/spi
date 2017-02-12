class Vertiginous
  def timeval(value)
    return lambda do
      value
    end
  end
  
  def randval
    return lambda do
      1/([1,2,3,4,8,9,12,16,24,32].choose.to_f)
    end
  end
  def initialize(parent, bpm=80)
    puts "HI"
    srand(Time.now.to_i)
    @parent = parent
    @parent.puts (1..24).map { @parent.scale(:d4, :major_pentatonic).choose }.inspect
    @parent.use_bpm bpm
    @instruments = {
      lead: :chiplead,
      bass: :subpulse,
      chords: :fm
    }
    v = ((1..24).map { @parent.scale(:d4, :major_pentatonic).choose } ).map { |x| [x, :random] }
    @parent.puts v.inspect
    @seqs = {
      lead: [
        
        (1..24).map { @parent.scale(:d4, :major_pentatonic).choose },
        (1..36).map { @parent.scale(:d4, :major).choose },
        #((1..24).map { @parent.scale(:d4, :major_pentatonic).choose } ).map { |x| y = randval.call; @parent.puts y; [x, y] }
      ],
      bass: [
        [
          [:d2, :sixth],
          [:d3, :sixth],
          [:a2, :sixth],
          [:d3, :third],
          [:g2, :third],
          [:cs2,:third],
          [:d2, 1.5],
        ]
      ],
      chords: [
        [
          [@parent.chord(:d3, :major), :fourbar],
          [@parent.chord(:a3, :major), :fourbar],
          [@parent.chord(:b3, :minor), :fourbar],
          [@parent.chord(:fs3, :minor), :fourbar],
          [@parent.chord(:g3, :major), :fourbar],
          [@parent.chord(:d3, :major), :fourbar],
          [@parent.chord(:g3, :major), :fourbar],
          [@parent.chord(:a3, :major), :fourbar]
        ]
      ]
    }
    @note_lengths = {
      fourbar:   timeval(0.25),
      twobar:    timeval(0.5),
      whole:     timeval(1),
      half:      timeval(2),
      triplet:   timeval(3),
      third:     timeval(3),
      quarter:   timeval(4),
      sextuplet: timeval(6),
      sixth:     timeval(6),
      eighth:    timeval(8),
      random:    randval,
    }
  end
  
  def note_length (length)
    if length.respond_to? :call
      return length.call
    elsif length.is_a? Symbol and @note_lengths[length]
      return @note_lengths[length].call
    elsif length.is_a? Numeric
      return length.to_f
    else
      return 3.0 # :triplet default
    end
  end
  
  def play_section (section)
    section = section.to_sym if section.is_a? String
    @parent.live_loop section do
      seq = @seqs[section].choose
      seq.map! { |element|
        if element.is_a? Array
          ret = [ element[0], note_length(element[1]) ]
          @parent.puts "return value: " + ret.inspect
          ret
        else
          [element, 3] #defunct default
        end
      }
      @parent.use_synth @instruments[section]
      seq.each do |element|
        note, divisor = element[0], element[1]
        @parent.puts "inst: #{section}, note: #{note}, divisor: #{divisor}"
        if section == :chords
          @parent.play_chord note, release: 4, amp: 4
        else
          @parent.play note, release: 1/6.0
        end
        @parent.sleep 1/divisor.to_f
      end
    end
  end
  
  def run
    @seqs.each_key do |section|
      play_section section
    end
    
    @parent.live_loop :bd do
      @parent.sample :bd_tek, amp: 4
      @parent.sleep (@parent.ring 1/0.5, 1/2.0, 1, 1/2.0, 1/0.5, 1/3.0, 1/3.0, 1/3.0, 1, 1/6.0, 1/6.0, 1/6.0, 1/1.5, 1/3.0).tick
    end
    
    @parent.live_loop :sd do
      @parent.sleep 1
      @parent.sample :sn_dolf
      @parent.sleep 1
    end
    
    @parent.live_loop :hh do
      @parent.sample :drum_cymbal_closed if @parent.one_in(1)
      @parent.sleep 1/3.0
    end
    @parent.live_loop :cym do
      @parent.sleep 1/3.0
      @parent.sample :drum_cymbal_soft if @parent.one_in(4)
      @parent.sleep 1-(1/3.0)
    end
    @parent.live_loop :crsh do
      @parent.sample :drum_splash_soft if @parent.one_in(6)
      @parent.sleep 1
    end
    @parent.live_loop :amen do
      @parent.with_fx :slicer, pulse_width: 0.75, wave: 0, prob_pos: 0.3, probability: 0.4 do
        @parent.sample :loop_amen_full, beat_stretch: 8
        @parent.sleep 8
      end
    end
  end
end
song = Vertiginous.new(self)
song.run








