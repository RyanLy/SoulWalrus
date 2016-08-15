import React from 'react'
import { Link, browserHistory } from 'react-router'
import request from 'superagent'

import AppBar from 'material-ui/AppBar';
import Drawer from 'material-ui/Drawer';
import MenuItem from 'material-ui/MenuItem';
import FontIcon from 'material-ui/FontIcon';
import {blue500, red500, greenA200} from 'material-ui/styles/colors';

class Index extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {open: false, points: []};
  }

  componentDidMount() {
    Notification.requestPermission()
    
    let pusher = new Pusher(ENVIRONMENT.PUSHER_APP_ID, {
      encrypted: true
    });
    
    let channelPoint = pusher.subscribe('point');

    channelPoint.bind('point_created', function(data) {
      request
      .get('/v1/point/most-recent')
      .end(function(err, res){
        let notif = new Notification(`A pokemon has appeared! It's ${res.body.result[0].friendly_name}!`,
                                     {icon: `https://s3-eu-west-1.amazonaws.com/calpaterson-pokemon/${res.body.result[0].friendly_id}.jpeg`})
        setTimeout(function(){
            notif.close();
        }, 10000);
      });
    })
  }
  
  handleToggle() { this.setState({open: !this.state.open}) }
      
  handleClose() { this.setState({open: false}) }
  
  render() {
    let styles = {
      top: '64px'
    }
    
    let overlayStyle = {
      opacity: 0
    }
    
    let pointerStyle = {
      cursor: 'pointer'
    }
    return (
      <div>
        <AppBar title="SoulWalrus" onTitleTouchTap={() => browserHistory.push('/')} titleStyle={pointerStyle  } onLeftIconButtonTouchTap={this.handleToggle.bind(this)} />
          <Drawer docked={false} overlayStyle={overlayStyle} containerStyle={styles} open={this.state.open} onRequestChange={(open) => this.setState({open})}>
            <Link to="/" className="router-link--underline--false">
              <MenuItem primaryText="Index"
                        onTouchTap={this.handleClose.bind(this)}
                        leftIcon={
                          <FontIcon className="material-icons" color={blue500}>home</FontIcon>
                        }
              />
            </Link>
            <Link to="/pokemon" className="router-link--underline--false">
              <MenuItem primaryText="Pokemon"
                        onTouchTap={this.handleClose.bind(this)}
                        leftIcon={
                          <FontIcon className="material-icons" color={greenA200}>pets</FontIcon>
                        }
              />
            </Link>
          </Drawer>
        { this.props.children }
      </div>
    )
  }
}

module.exports = Index
