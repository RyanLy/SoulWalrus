import React from 'react'
import request from 'superagent'
import Pusher from 'pusher-js';

import {Tabs, Tab} from 'material-ui/Tabs';

import PokeTable from './PokeTable.jsx';
import Loading from './Loading.jsx';
import Leaderboard from './Leaderboard.jsx';
import Error from './Error.jsx';
import FontIcon from 'material-ui/FontIcon';

let pusher = new Pusher(ENVIRONMENT.PUSHER_APP_ID, {
  encrypted: true
});

let channelPoint = pusher.subscribe('point');

class Pokemon extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      loading_most_recent: true,
      loading_leaderboard: true,
      points: [],
      leaderboard: {},
    };
  }
  
  componentDidMount() {
    Notification.requestPermission()
    
    request
    .get('/v1/point/most-recent')
    .end((err, res) => {
      this.setState({
        points: res.body.result,
        loading_most_recent: false,
      });
    });

    request
    .get('/v1/point/leaderboard')
    .end((err, res) => {
      this.setState({
        leaderboard: res.body.result,
        loading_leaderboard: false,
      });
    });

    channelPoint.bind('point_created', function(data) {
      request
      .get('/v1/point/most-recent')
      .end((err, res) => {
        this.setState({
          points: res.body.result,
        });
      });
    })
    
    channelPoint.bind('point_updated', function(data) {
      request
      .get('/v1/point/most-recent')
      .end((err, res) => {
        this.setState({
          points: res.body.result,
        });
      });
    })
  }
  
  componentWillUnmount() {
    channelPoint.unbind('point_created');
    channelPoint.unbind('point_updated');
  }

  render() {
    return (
      <div className="container">
        <h1>Recent 5 Pokemon and Leaderboards</h1>
        <hr/>
        <Tabs>
          <Tab icon={<FontIcon className="material-icons">replay_5</FontIcon>} label="Recent">
            {
              this.state.loading_most_recent
              ?
              <Loading />
              :
              <PokeTable points={this.state.points} />
            }
          </Tab>
          <Tab icon={<FontIcon className="material-icons">star</FontIcon>} label="Leaderboards">
            {
              this.state.loading_leaderboard
              ?
              <Loading />
              :
              <Leaderboard leaderboard={this.state.leaderboard}/>
            }
          </Tab>
        </Tabs>
      </div>
    )
  }
}

module.exports = Pokemon
