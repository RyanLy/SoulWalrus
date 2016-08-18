import React from 'react'
import request from 'superagent'

import PokeTable from './PokeTable.jsx';
import Loading from './Loading.jsx';

class PokemonId extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      loading: true,
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
