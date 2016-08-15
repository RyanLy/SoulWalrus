import React from 'react'
import request from 'superagent'
import Pusher from 'pusher-js';

import {Tabs, Tab} from 'material-ui/Tabs';

import PokeTable from './PokeTable.jsx';
import Loading from './Loading.jsx';
import Leaderboard from './Leaderboard.jsx';
import Error from './Error.jsx';


let pusher = new Pusher(ENVIRONMENT.PUSHER_APP_ID, {
  encrypted: true
});

let channelPoint = pusher.subscribe('point');

class Pokemon extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      loading: true,
      points: [],
      leaderboard: {},
    };
  }
  
  componentDidMount() {
    Notification.requestPermission()
    
    let self = this;
    request
    .get('/v1/point/most-recent')
    .end(function(err, res){
      self.setState({
        points: res.body.result,
        loading: false,
      });
    });

    request
    .get('/v1/point/leaderboard')
    .end(function(err, res){
      self.setState({
        leaderboard: res.body.result,
      });
    });

    channelPoint.bind('point_created', function(data) {
      request
      .get('/v1/point/most-recent')
      .end(function(err, res){
        console.log(res);
        self.setState({
          points: res.body.result,
        });
      });
    })
    
    channelPoint.bind('point_updated', function(data) {
      request
      .get('/v1/point/most-recent')
      .end(function(err, res){
        self.setState({
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
        <h1> Recent 5 Pokemon and Leaderboards</h1>
        <hr/>
        <Tabs>
          <Tab label="Recent">
            {
             this.state.loading
             ?
             <Loading />
             :
             <PokeTable points={this.state.points} />
            }
          </Tab>
          <Tab label="Leaderboards">
            <Leaderboard leaderboard={this.state.leaderboard}/>
          </Tab>
        </Tabs>
      </div>
    )
  }
}

module.exports = Pokemon
