require 'spec_helper'

describe SocialProfile::People::Google do
  let(:user) { SocialProfile::Person.get(:google, nil, ENV['GOOGLE_ACCESS_TOKEN']) }

  it 'should be a Module' do
    expect(described_class).to be_a Module
  end

  it 'should be a google profile' do
    expect(user).to be_a described_class
  end

  it 'should response to friends_count' do
    expect(user.friends_count).to be_a Integer
  end

  it 'fetches channel title' do
    expect(user.channel_title).to be_a String
  end

  it 'fetches channel keywords' do
    expect(user.channel_keywords).to be_an Array
  end

  it 'fetches channel video count' do
    expect(user.channel_video_count).to be_an Integer
  end

  it 'fetches channel videos view count' do
    expect(user.channel_view_count).to be_an Integer
  end

  it 'fetches channel country' do
    expect(user.channel_country).to be_a String
  end

  it 'fetches channel categories' do
    expect(user.channel_categories).to be_any
  end

  it 'fetches subscription channels' do
    expect(user.subscription_channels).to all(be_a(described_class))
  end

  it 'fetches last videos like count' do
    expect(user.last_like_count).to be_an Integer
  end

  it 'fetches last videos view count' do
    expect(user.last_view_count).to be_an Integer
  end

  it 'fetches last videos comment count' do
    expect(user.last_comment_count).to be_an Integer
  end
end
