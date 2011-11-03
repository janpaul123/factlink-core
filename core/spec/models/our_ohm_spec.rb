require "rubygems"
require "bundler/setup"
require 'ohm'
require 'active_model'
require 'canivete'
require File.expand_path('../../../app/ohm-models/our_ohm.rb', __FILE__)

class Item < OurOhm
end

class Container < OurOhm
  set :items, Item
  sorted_set :sorted_items, Item do |x|
    1
  end
end


    

describe Ohm::Model::Set do
  it "should have a working union" do
    c1 = Container.create()
    c2 = Container.create()
    a = Item.create()
    b = Item.create()
    c1.items << a
    c2.items << b
    union = c1.items | c2.items
    c1.items.all.should =~ [a]
    c2.items.all.should =~ [b]
    union.all.should =~ [a,b]
  end
  
end

describe Ohm::Model::SortedSet do
  describe "union" do
    before do
      @c1 = Container.create()
      @c2 = Container.create()
      @a = Item.create()
      @b = Item.create()
      @c1.sorted_items << @a
      @c2.sorted_items << @b
      @union = @c1.sorted_items | @c2.sorted_items
    
    end
    it { @c1.sorted_items.all.should =~ [@a] }
    it { @c2.sorted_items.all.should =~ [@b] }
    it { @union.all.should =~ [@a,@b] }
    it do
      @c3 = Container.create()
      @union.all.should =~ [@a,@b]
      @c3.sorted_items = @union
      @c3.sorted_items.all.should =~ [@a,@b]
      
      @c3.sorted_items = @c1.sorted_items
      @c3.sorted_items.all.should =~ [@a]
    end
  end 
  
  
  it "should have a working difference" do
    c1 = Container.create()
    c2 = Container.create()
    a = Item.create()
    b = Item.create()
    c1.sorted_items << a << b
    c2.sorted_items << a
    diff = c1.sorted_items - c2.sorted_items
    c1.sorted_items.all.should =~ [a,b]
    c2.sorted_items.all.should =~ [a]
    diff.all.should =~ [b]
    
    c1.sorted_items.delete(b)
    diff = c1.sorted_items - c2.sorted_items
    c1.sorted_items.all.should =~ [a]
    c2.sorted_items.all.should =~ [a]
    diff.all.should =~ []
  end
end

describe OurOhm do
  it "should do normal with collections" do
    class Root < OurOhm
      set :rootitems, Item
    end
    class A < Root
      set :aitems, Item
    end
    class B < Root
      set :bitems, Item
    end
    Root.collections.should =~ [:rootitems]
    A.collections.should =~ [:rootitems, :aitems]
    B.collections.should =~ [:rootitems, :bitems]
  end
end