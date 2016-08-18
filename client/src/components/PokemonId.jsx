import React from 'react'
import request from 'superagent'
import { Link } from 'react-router'
import RaisedButton from 'material-ui/RaisedButton';
import FontIcon from 'material-ui/FontIcon';
import {orange500} from 'material-ui/styles/colors';

import PokeTable from './PokeTable.jsx';
import Loading from './Loading.jsx';

class PokemonId extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      loading: true,
      points: {}
    };
  }
  
  componentDidMount() {
    request
    .get(`/v1/point-id/${this.props.params.friendly_id}`)
    .end((err, res) => {
      this.setState({
        points: res.body.result,
        loading: false
      });
    });
  }
  
  componentWillReceiveProps(nextProps) {
    this.setState({
      loading: true,
      points: {}
    });
    
    request
    .get(`/v1/point-id/${nextProps.params.friendly_id}`)
    .end((err, res) => {
      this.setState({
        points: res.body.result,
        loading: false
      });
    });
  }
  
  render() {
    const style = {
      height: 100,
      width: 100,
      margin: 20,
      textAlign: 'center',
      display: 'inline-block',
    };
    const img_style = {
      height: 100,
      width: 100,
      borderRadius: '50%'
    }
    return (
      <div className="container">
        <div className="row margin-top-15px">
          {
            this.props.params.friendly_id > 1
            ?
            <div className="pull-left">
              <Link to={`/pokemon-id/${parseInt(this.props.params.friendly_id) - 1}`}
                    className="router-link--underline--false">
                <RaisedButton
                  label={`Previous (${parseInt(this.props.params.friendly_id) - 1})`}
                  icon={<FontIcon className="material-icons">chevron_left</FontIcon>}
                />
              </Link>
            </div>
            :
            null
          }
          {
            this.props.params.friendly_id < 151
            ?
            <div className="pull-right">
              <Link to={`/pokemon-id/${parseInt(this.props.params.friendly_id) + 1}`}
                    className="router-link--underline--false">
                <RaisedButton
                  label={`Next (${parseInt(this.props.params.friendly_id) + 1})`}
                  labelPosition="before"
                  icon={<FontIcon className="material-icons">chevron_right</FontIcon>}
                />
              </Link>
            </div>
            :
            null
            
          }

        </div>
        <h1>Results for id: {this.props.params.friendly_id}
            {this.state.points && this.state.points.length > 0 && (" - " + this.state.points[0].friendly_name) }
        </h1>
        <hr/>
        {
          this.state.loading
          ?
          <Loading />
          :
          <PokeTable points={this.state.points} />
        }
      </div>
    )
  }
}

module.exports = PokemonId
