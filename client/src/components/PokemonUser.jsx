import React from 'react'
import request from 'superagent'
import RefreshIndicator from 'material-ui/RefreshIndicator';
import Paper from 'material-ui/Paper';
import PokeTable from './PokeTable.jsx';
import Loading from './Loading.jsx';

class PokemonUser extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      loading: true,
    };
  }
  
  componentDidMount() {
    let self = this;
    request
    .get(`/v1/point/${this.props.params.user_name}`)
    .end(function(err, res){
      self.setState({
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
        <h1> {this.props.params.user_name + "'s - "} Pokemon </h1>
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

module.exports = PokemonUser
