import React from 'react'
import { Link } from 'react-router'

import Paper from 'material-ui/Paper';
import ReactTooltip from 'react-tooltip'

class PokeImage extends React.Component {

  constructor(props) {
    super(props);
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
      <div>
        <Link to={'/pokemon-id/' + this.props.point.friendly_id} className="router-link--underline--false">
          <Paper data-tip={`${this.props.point.friendly_name} (${this.props.point.friendly_id})`} style={style} zDepth={2} circle={true} children={  
            <img style={img_style} src={'https://s3-eu-west-1.amazonaws.com/calpaterson-pokemon/' + this.props.point.friendly_id + '.jpeg'} />} 
          />
        </Link>
        <ReactTooltip />
      </div>
    )
  }
}

module.exports = PokeImage
