require File.expand_path("../../spec_helper", __FILE__)

module Bamboo
  module Client
    describe Rest do
      let(:http) { mock(Http::Json) }
      let(:document) { mock(Http::Json::Doc) }
      let(:client) { Rest.new(http) }

      it "should be able to fetch plans" do
        document.should_receive(:auto_expand).with(Rest::Plan, http).and_return %w[foo bar]

        http.should_receive(:get).with(
          "/rest/api/latest/plan/",
          nil,
          nil
        ).and_return(document)

        client.plans.should == %w[foo bar]
      end

      it "should be able to fetch projects" do
        document.should_receive(:auto_expand).with(Rest::Project, http).and_return %w[foo bar]

        http.should_receive(:get).with("/rest/api/latest/project/", nil, nil).
                                  and_return(document)

        client.projects.should == %w[foo bar]
      end

      it "should be able to fetch builds" do
        document.should_receive(:auto_expand).with(Rest::Build, http).and_return %w[foo bar]

        http.should_receive(:get).with("/rest/api/latest/build/", nil, nil).
                                  and_return(document)

        client.builds.should == %w[foo bar]
      end

      describe Rest::Plan do
        let(:data) { json_fixture("plan") }
        let(:plan) { Rest::Plan.new data, http  }

        it "knows if the plan is enabled" do
          plan.should be_enabled
        end

        it "has a type" do
          plan.type.should == :chain
        end

        it "has a name" do
          plan.name.should == "Selenium 2 Ruby - WebDriver Remote Client Tests - Windows"
        end

        it "has a key" do
          plan.key.should == "S2RB-REMWIN"
        end

        it "has a URL" do
          plan.url.should == "http://xserve.openqa.org:8085/rest/api/latest/plan/S2RB-REMWIN"
        end

        it "can be queued" do
          http.should_receive(:post).with("/rest/api/latest/queue/S2RB-REMWIN")
          plan.queue
        end
      end # Plan

      describe Rest::Project do
        let(:data) { json_fixture("project") }
        let(:plan) { Rest::Project.new data, http  }

        it "has a name" do
          plan.name.should == "Selenium 2 Java"
        end

        it "has a key" do
          plan.key.should == "S2J"
        end

        it "has a URL" do
          plan.url.should == "http://xserve.openqa.org:8085/rest/api/latest/project/S2J"
        end
      end

      describe Rest::Build do
        let(:data) { json_fixture("build") }
        let(:build) { Rest::Build.new data, http }

        it "has a key" do
          build.key.should == "IAD-DEFAULT-5388"
        end

        it "has a state" do
          build.state.should == :successful
        end

        it "has an id" do
          build.id.should == 8487295
        end

        it "has a number" do
          build.number.should == 5388
        end

        it "has a life cycle state" do
          build.life_cycle_state.should == :finished
        end

        it "has a URL" do
          build.url.should == "http://localhost:8085/rest/api/latest/result/IAD-DEFAULT-5388"
        end

        it "has a list of changes" do
          # TODO: arg expectation
          http.should_receive(:get).and_return Http::Json::Doc.new(json_fixture("build_with_changes"))
          build.changes.first.should be_kind_of(Rest::Change)
        end
      end

      describe Rest::Change do
        let(:data) { json_fixture("change") }
        let(:change) { Rest::Change.new data, http }

        it "has an id" do
          change.id.should == "131"
        end

        it "has a date" do
          change.date.should == Time.parse("2011-01-20T10:04:47.000+01:00")
        end

        it "has an author" do
          change.author.should == "joedev"
        end

        it "has a full name" do
          change.full_name.should == "Joe Developer"
        end

        it "has a username" do
          change.user_name.should == "joedev"
        end

        it "has a comment" do
          change.comment.should == "Fixed the config thing."
        end

        it "has a list of files" do
          change.files.first.should == {:name => "/trunk/server/src/main/resources/some-config.ini", :revision => "131"}
        end
      end


    end # Rest
  end # Client
end # Bamboo
