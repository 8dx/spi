class Vertiginous
  def initialize(parent, bpm=80)
    @parent = parent
    @parent.use_bpm bpm
    @seqs = {
      lead: [
        [:c4, :e4, :g4, :f4, :g4],
        [:c4, :g4, :gs4, :g4, :d4],
      ],
      bass: [
        [
          [:c2, :sixth],
          [:c3, :sixth],
          [:g2, :sixth],
          [:c3, :third],
          [:f2, :third],
          [:ab2,:third],
          [:c2, 1.5],
        ]
      ],
      chords: [
        [
          [@parent.chord(:c3, :minor), :whole],
          [@parent.chord(:g3, :minor), :whole],
          [@parent.chord(:ab3, :major), :whole],
          [@parent.chord(:eb3, :major), :whole],
          [@parent.chord(:f3, :minor), :whole],
          [@parent.chord(:c3, :minor), :whole],
          [@parent.chord(:f3, :minor), :whole],
          [@parent.chord(:g3, :minor), :whole]
        ]
      ]
    }
    @note_lengths = {
      whole:     1,
      half:      2,
      triplet:   3,
      third:     3,
      quarter:   4,
      sextuplet: 6,
      sixth:     6,
      eighth:    8,
    }
  end
  
  def note_length (length)
    
    if length.is_a? Symbol and @note_lengths[length]
      return @note_lengths[length]
    elsif length.is_a? Numeric
      return length.to_f
    else
      return 3 # :triplet default
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
      instrument = :chiplead
      @parent.use_synth instrument
      seq.each do |element|
        note, divisor = element[0], element[1]
        @parent.puts "inst: #{section}, note: #{note}, divisor: #{divisor}"
        if section == :chords
          @parent.play_chord note, release: 1/3.0, amp: 4
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
      @parent.sample :bd_tek
      @parent.sleep (@parent.ring 2, 0.5, 1, 0.5, 2).tick
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
  end
end
song = Vertiginous.new(self)
song.run






