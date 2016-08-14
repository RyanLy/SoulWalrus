import React from 'react'
import request from 'superagent'
import Pusher from 'pusher-js';

import PokeTable from './PokeTable.jsx';
import Loading from './Loading.jsx';

let pusher = new Pusher(ENVIRONMENT.PUSHER_APP_ID, {
  encrypted: true
});

let channelPoint = pusher.subscribe('point');

class Pokemon extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      loading: true,
      open: false
    };
  }
  
  componentDidMount() {
    Notification.requestPermission()
    
    self = this;
    request
    .get('/v1/point/most-recent')
    .end(function(err, res){
      self.setState({
        points: res.body.result,
        loading: false
      });
    });

    channelPoint.bind('point_created', function(data) {
      request
      .get('/v1/point/most-recent')
      .end(function(err, res){
        self.setState({
          points: res.body.result,
          open: true
        });
      });
    })
    
    channelPoint.bind('point_updated', function(data) {
      request
      .get('/v1/point/most-recent')
      .end(function(err, res){
        self.setState({
          points: res.body.result,
          open: true
        });
      });
    })
  }
  
  componentWillUnmount() {
    channelPoint.unbind('point_created');
  }

  render() {

    return (
      <div>
        <div className="container">
          <h1> Recent 5 Pokemon ... </h1>
          
          {
            this.state.loading
            ?
            <Loading />
            :
            <PokeTable points={this.state.points} />
          }
        </div>
      </div>
    )
  }
}

module.exports = Pokemon
